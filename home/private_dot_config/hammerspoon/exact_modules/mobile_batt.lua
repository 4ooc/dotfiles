local M = {}
local host = "t.x"
local normalInterval = 180
local highFrequencyInterval = 60
local failureIntervals = { 60, 180, 300, 600 }
local lowThreshold = 20
local lowWarningWindow = 25
local highThreshold = 78
local debugLogging = true

local checkBattery

M.lastNotify = {
	low = nil,
	high = nil,
}

M.failureCount = 0

local function log(fmt, ...)
	if not debugLogging then
		return
	end

	hs.printf("[mobile_batt] " .. fmt, ...)
end

local function trim(value)
	if not value then
		return ""
	end

	return value:match("^%s*(.-)%s*$") or ""
end

local function withdrawNotification(name)
	if M.lastNotify[name] then
		M.lastNotify[name]:withdraw()
		M.lastNotify[name] = nil
	end
end

local function sendNotification(name, title, text)
	if M.lastNotify[name] then
		return
	end

	log("send notification=%s text=%s", name, text)

	M.lastNotify[name] = hs.notify
		.new({
			title = title,
			informativeText = text,
			withdrawAfter = 300,
		})
		:send()
end

local function notifyBattery(percent, plugged)
	if plugged == "UNPLUGGED" then
		withdrawNotification("high")
		if percent < lowThreshold then
			sendNotification("low", "手机电量低", "手机电量 " .. percent .. "% ，请充电！")
		else
			withdrawNotification("low")
		end
	elseif plugged == "PLUGGED_AC" then
		withdrawNotification("low")
		if percent > highThreshold then
			sendNotification("high", "手机电量高", "手机电量 " .. percent .. "% ，可以拔掉充电器了！")
		else
			withdrawNotification("high")
		end
	end
end

local function scheduleNextCheck(delay)
	if M.timer then
		M.timer:stop()
		M.timer = nil
	end

	log("schedule next check in %ss", delay)

	M.timer = hs.timer.doAfter(delay, function()
		M.timer = nil
		checkBattery()
	end)
end

local function nextSuccessInterval(percent, plugged)
	if plugged == "PLUGGED_AC" then
		return highFrequencyInterval
	end

	if plugged == "UNPLUGGED" and percent <= lowWarningWindow then
		return highFrequencyInterval
	end

	return normalInterval
end

local function nextFailureInterval()
	local index = math.min(M.failureCount + 1, #failureIntervals)
	return failureIntervals[index]
end

checkBattery = function()
	if M.sshTask then
		log("skip check: ssh task already running")
		return
	end

	log("start check failure_count=%d", M.failureCount)

	M.sshTask = hs.task.new("/usr/bin/ssh", function(exitCode, stdOut, stdErr)
		M.sshTask = nil

		if exitCode ~= 0 or not stdOut or stdOut == "" then
			M.failureCount = math.min(M.failureCount + 1, #failureIntervals)
			local nextDelay = nextFailureInterval()
			log(
				"ssh failed exit=%s stderr=%s next=%ss failure_count=%d",
				tostring(exitCode),
				trim(stdErr),
				nextDelay,
				M.failureCount
			)
			scheduleNextCheck(nextDelay)
			return
		end

		local ok, data = pcall(hs.json.decode, stdOut)
		if not ok or not data then
			M.failureCount = math.min(M.failureCount + 1, #failureIntervals)
			local nextDelay = nextFailureInterval()
			log("decode failed next=%ss failure_count=%d", nextDelay, M.failureCount)
			scheduleNextCheck(nextDelay)
			return
		end

		local percent = tonumber(data.percentage)
		local plugged = data.plugged
		if percent == nil or plugged == nil then
			M.failureCount = math.min(M.failureCount + 1, #failureIntervals)
			local nextDelay = nextFailureInterval()
			log("payload invalid next=%ss failure_count=%d payload=%s", nextDelay, M.failureCount, trim(stdOut))
			scheduleNextCheck(nextDelay)
			return
		end

		M.failureCount = 0
		notifyBattery(percent, plugged)
		local nextDelay = nextSuccessInterval(percent, plugged)
		log("success percent=%d plugged=%s next=%ss", percent, plugged, nextDelay)
		scheduleNextCheck(nextDelay)
	end, {
		host,
		"-o",
		"ControlMaster=no",
		"-o",
		"ControlPersist=0m",
		"termux-battery-status",
	})

	log("spawn ssh host=%s", host)
	M.sshTask:start()
end

checkBattery()

return M
