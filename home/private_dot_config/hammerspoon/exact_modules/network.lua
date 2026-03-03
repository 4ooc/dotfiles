local function run(cmd)
	local output = hs.execute(cmd)
	if output == nil then
		return ""
	end
	return output:gsub("%s+$", "")
end

local preCarrier = ""
local function checkNetwork()
	local carrier = run("curl -s cip.cc  | awk -F: '/运营商/{print $2}' | xargs")
	if preCarrier == carrier then
		return
	end

	preCarrier = carrier

	if carrier == "移动" or carrier == "联通" then
		hs.alert.show("当前运营商: " .. carrier)
	end
end

KEEP = hs.timer.doEvery(60, checkNetwork)

checkNetwork()

LST = hs.timer
	.new(300, function()
		local audio = hs.audiodevice.defaultEffectDevice()
		local lockInteval = (audio and audio:inUse()) and 900 or 300
		local idleTime = hs.host.idleTime()
		local remaining = lockInteval - idleTime
		if remaining <= 10 then
			print("remain lock")
			hs.caffeinate.lockScreen()
		end
	end)
	:start()

local hcw = hs.caffeinate.watcher
local c_tbl = {
	[hcw.screensaverDidStart] = "screensaverDidStart",
	[hcw.screensaverDidStop] = "screensaverDidStop",
	[hcw.screensaverWillStop] = "screensaverWillStop",
	[hcw.screensDidLock] = "screensDidLock",
	[hcw.screensDidSleep] = "screensDidSleep",
	[hcw.screensDidUnlock] = "screensDidUnlock",
	[hcw.screensDidWake] = "screensDidWake",
	[hcw.sessionDidBecomeActive] = "sessionDidBecomeActive",
	[hcw.sessionDidResignActive] = "sessionDidResignActive",
	[hcw.systemDidWake] = "systemDidWake",
	[hcw.systemWillPowerOff] = "systemWillPowerOff",
	[hcw.systemWillSleep] = "systemWillSleep",
}

CW = hcw.new(function(event_type)
	-- print(c_tbl[event_type])
	if event_type == hcw.screensDidLock then
		hs.execute("/opt/homebrew/bin/media-control pause")
		LST:stop()
	elseif event_type == hcw.screensDidUnlock then
		LST:start()
	end
end):start()
