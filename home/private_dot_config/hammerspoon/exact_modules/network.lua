local M = {}
local preCarrier = ""
M.isScreenLocked = false

local function trim(value)
	if not value then
		return ""
	end
	return value:match("^%s*(.-)%s*$") or ""
end

local function parseCarrier(output)
	for line in (output or ""):gmatch("[^\r\n]+") do
		local carrier = line:match("运营商%s*:%s*(.+)")
		if carrier then
			return trim(carrier)
		end
	end

	return ""
end

local function checkNetwork()
	if M.isScreenLocked then
		return
	end

	if M.carrierTask then
		return
	end

	M.carrierTask = hs.task.new("/usr/bin/curl", function(exitCode, stdOut, stdErr)
		M.carrierTask = nil
		if exitCode ~= 0 or not stdOut or stdOut == "" then
			if stdErr and stdErr ~= "" then
				print("checkNetwork failed: " .. trim(stdErr))
			end
			return
		end

		local carrier = parseCarrier(stdOut)
		if carrier == "" or preCarrier == carrier then
			return
		end

		preCarrier = carrier

		if carrier == "移动" or carrier == "联通" then
			hs.alert.show("当前运营商: " .. carrier)
		end
	end, { "-fsSL", "--max-time", "3", "cip.cc" })

	M.carrierTask:start()
end

M.keepTimer = hs.timer.doEvery(60, checkNetwork)

checkNetwork()

M.lockScreenTimer = hs.timer
	.new(300, function()
		local audio = hs.audiodevice.defaultEffectDevice()
		local lockInteval = (audio and audio:inUse()) and 900 or 300
		local idleTime = hs.host.idleTime()
		local remaining = lockInteval - idleTime
		if remaining <= 10 then
			hs.caffeinate.lockScreen()
		end
	end)
	:start()

local function pauseMedia()
	if M.mediaPauseTask then
		return
	end

	M.mediaPauseTask = hs.task.new("/opt/homebrew/bin/media-control", function()
		M.mediaPauseTask = nil
	end, { "pause" })

	M.mediaPauseTask:start()
end

local hcw = hs.caffeinate.watcher

M.caffeinateWatcher = hcw.new(function(event_type)
	if event_type == hcw.screensDidLock then
		M.isScreenLocked = true
		pauseMedia()
		M.keepTimer:stop()
		M.lockScreenTimer:stop()
	elseif event_type == hcw.screensDidUnlock then
		M.isScreenLocked = false
		M.keepTimer:start()
		checkNetwork()
		M.lockScreenTimer:start()
	end
end):start()

return M
