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
	local width = 24
	self.canvas[1] = {
		type = "text",
		text = drawInfo.iconText,
		textSize = drawInfo.textSize,
		textFont = "Delugia Mono",
		textAlignment = "center",
		trackMouseEnterExit = true,
		frame = { x = 0, y = 20 - drawInfo.frameHeight, w = width, h = drawInfo.frameHeight },
	}

	local index = 2
	local strokeY = 0.5
	if drawInfo.isAC then
		if drawInfo.isCharging then
			strokeY = 18.5
		end

		-- underscore
		self.canvas[index] = {
			type = "rectangle",
			action = "stroke",
			strokeWidth = 1,
			roundedRectRadii = { xRadius = 0, yRadius = 0 },
			frame = { x = 0, y = strokeY, w = width, h = 1 },
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
function drawInfo:setIconParams(iconText, textSize, frameHeight)
	self.iconText = iconText
	self.textSize = textSize
	self.frameHeight = frameHeight
end

function drawInfo:computeIconParams()
	local letters = fill_letters
	local percentageText = ""
	local frameHeight = 22.5
	local textSize = 20
	if self.percentage == 100 then
		textSize = 30
		frameHeight = 27
		percentageText = (self.isCharging and self.isAC) and "" or "󰙴"
	else
		local percentage = self.percentage
		local index = 0
		while percentage >= 1 do
			index = (percentage % 10) + 1
			index, _ = math.modf(index)
			percentageText = letters[index] .. percentageText
			percentage = percentage / 10
		end

		if self.isAC then
			frameHeight = self.isCharging and 23 or 21
		end
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
	local batt_info = hs.battery.getAll()

	local precent = batt_info.percentage
	local isAC = batt_info.powerSource == "AC Power"
	local isCharging = batt_info.isCharging

	if batt_info.capacity < 200 and not isAC then
		showChargingReminder()
	else
		hideChargingReminder()
	end

	if precent == drawInfo.percentage and isAC == drawInfo.isAC and isCharging == drawInfo.isCharging then
		return
	end

	print(string.format("Battery: (%d) (%d/%d)", batt_info.percentage, batt_info.capacity, batt_info.maxCapacity))

	drawInfo.percentage = precent
	drawInfo.isAC = isAC
	drawInfo.isCharging = isCharging

	drawInfo:computeIconParams()
	menu:setMenubarIcon(drawInfo)
end

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

menu:analyzeAndSetMenubarIcon()

batteryWatcher = hs.battery.watcher
	.new(function()
		menu:analyzeAndSetMenubarIcon()
	end)
	:start()

cw = hcw.new(function(event_type)
	print(c_tbl[event_type])
	if event_type == hcw.screensDidLock then
		batteryWatcher:stop()
	elseif event_type == hcw.screensDidUnlock then
		batteryWatcher:start()
	end
end):start()
