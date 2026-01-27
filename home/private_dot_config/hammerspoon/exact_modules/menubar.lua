local hs = hs

local menu = {}
local drawInfo = {}
menu.menubar = hs.menubar.new()
menu.canvas = hs.canvas.new({ x = 0, y = 0, w = 24, h = 20 })
menu.menubar:setMenu({
	{
		title = "Reset Config",
		fn = function()
			hs.reload()
		end,
	},
	{ title = "-" },
	{
		title = "Open Console",
		fn = function()
			hs.openConsole()
		end,
	},
})

function menu:setMenubarIcon(drawInfo)
	local width = 22
	self.canvas[1] = {
		type = "text",
		text = drawInfo.iconText,
		textSize = drawInfo.textSize,
		textAlignment = "center",
		trackMouseEnterExit = true,
		frame = { x = 0, y = 20 - drawInfo.frameHeight, w = width, h = drawInfo.frameHeight },
	}

	local index = 2
	local strokeY = 2.5
	if drawInfo.isAC then
		if drawInfo.isCharging then
			strokeY = 17
		end

		-- underscore
		self.canvas[index] = {
			type = "rectangle",
			action = "stroke",
			strokeWidth = 1,
			roundedRectRadii = { xRadius = 0, yRadius = 0 },
			frame = { x = 0, y = strokeY, w = width - 1, h = 1 },
		}
		index = index + 1
	else
		if self.canvas[index] ~= nil then
			self.canvas:removeElement(index)
		end
	end

	self.canvas:size({ x = 0, y = 0, w = width, h = 20 })
	self.menubar:setIcon(self.canvas:imageFromCanvas())
end

local fill_letters = { "𝟎", "𝟏", "𝟐", "𝟑", "𝟒", "𝟓", "𝟔", "𝟕", "𝟖", "𝟗" }
function drawInfo:refreshBattInfo()
	local precent = hs.battery.percentage()
	local isAC = hs.battery.powerSource() == "AC Power"
	local isCharging = hs.battery.isCharging()

	self.capacity = hs.battery.capacity()

	if precent == self.percentage and isAC == self.isAC and isCharging == self.isCharging then
		self.refreshed = false
	else
		print(string.format("Battery: (%d) (%d/%s)", precent, self.capacity, hs.battery.maxCapacity()))
		self.refreshed = true
		self.percentage = precent
		self.isAC = isAC
		self.isCharging = isCharging
	end
end

function drawInfo:setIconParams(iconText, textSize, frameHeight)
	self.iconText = iconText
	self.textSize = textSize
	self.frameHeight = frameHeight
end

function drawInfo:computeIconParams()
	local letters = fill_letters
	local percentageText = ""
	local frameHeight = 21.5
	local textSize = 19

	local percentage = self.percentage
	local index = 0
	while percentage >= 1 do
		index = (percentage % 10) + 1
		index, _ = math.modf(index)
		percentageText = letters[index] .. percentageText
		percentage = percentage / 10
	end

	percentageText = string.sub(percentageText, -8)

	if self.isAC then
		textSize = 18
		frameHeight = self.isCharging and 22 or 19.5
	end
	self:setIconParams(percentageText, textSize, frameHeight)
end

local chargingCanvas = nil
local escWatcher = nil

function showChargingReminder()
	if chargingCanvas then
		return
	end

	local screenFrame = hs.screen.mainScreen():fullFrame()
	chargingCanvas = hs.canvas.new(screenFrame):show()

	chargingCanvas[1] = {
		type = "rectangle",
		action = "fill",
		fillColor = { red = 0.1, green = 0.1, blue = 0.1, alpha = 0.8 },
	}

	chargingCanvas[2] = {
		type = "text",
		text = "⚡ Plug in your charger!",
		textSize = 48,
		textColor = { white = 1 },
		textAlignment = "center",
		frame = {
			x = "0%",
			y = "40%",
			w = "100%",
			h = "20%",
		},
	}

	escWatcher = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(event)
		if event:getKeyCode() == hs.keycodes.map.escape then
			hideChargingReminder()
		end
		return false
	end)
	escWatcher:start()
end

function hideChargingReminder()
	if chargingCanvas then
		chargingCanvas:delete()
		chargingCanvas = nil
	end
	if escWatcher then
		escWatcher:stop()
		escWatcher = nil
	end
end

function menu:analyzeAndSetMenubarIcon()
	drawInfo:refreshBattInfo()
	if drawInfo.capacity < 144 and not drawInfo.isAC then
		showChargingReminder()
	else
		hideChargingReminder()
	end

	if not drawInfo.refreshed then
		return
	end

	drawInfo:computeIconParams()
	menu:setMenubarIcon(drawInfo)
end

menu:analyzeAndSetMenubarIcon()

BW = hs.battery.watcher
	.new(function()
		menu:analyzeAndSetMenubarIcon()
	end)
	:start()

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
		BW:stop()
		LST:stop()
	elseif event_type == hcw.screensDidUnlock then
		BW:start()
		LST:start()
	end
end):start()
