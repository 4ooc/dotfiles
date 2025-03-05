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

function menu:analyzeAndSetMenubarIcon()
	local batt_info = hs.battery.getAll()

	local realPrecent = math.ceil(100 * batt_info.capacity / batt_info.maxCapacity + 0.3)
	local isAC = batt_info.powerSource == "AC Power"
	local isCharging = batt_info.isCharging

	if bw ~= nil then
		if batt_info.capacity < 150 or isAC then
			bw:setNextTrigger(10)
		else
			bw:setNextTrigger(60)
		end
	end

	if realPrecent == drawInfo.percentage and isAC == drawInfo.isAC and isCharging == drawInfo.isCharging then
		return
	end

	print(
		string.format(
			"Battery: (%d)[%d] (%d/%d)",
			batt_info.percentage,
			realPrecent,
			batt_info.capacity,
			batt_info.maxCapacity
		)
	)

	drawInfo.percentage = realPrecent
	drawInfo.isAC = isAC
	drawInfo.isCharging = isCharging

	drawInfo:computeIconParams()
	menu:setMenubarIcon(drawInfo)
end

bw = hs.timer
	.new(60, function()
		menu:analyzeAndSetMenubarIcon()
	end)
	:fire()
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

cw = hcw.new(function(event_type)
	print(c_tbl[event_type])
	if event_type == hcw.screensDidLock then
		bw:stop()
	elseif event_type == hcw.screensDidUnlock then
		bw:fire():start()
	end
end):start()
