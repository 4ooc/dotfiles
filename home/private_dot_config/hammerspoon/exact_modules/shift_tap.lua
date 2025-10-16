local englishInputSource = "com.apple.keylayout.ABC"
local chineseInputSource = "im.rime.inputmethod.Squirrel.Hans"

local tapDuration = 0.25

local leftShiftKeyCode = 56
local rightShiftKeyCode = 60
local shiftKeyCodes = { [leftShiftKeyCode] = "left", [rightShiftKeyCode] = "right" }

local shiftKeyDownTime = { left = nil, right = nil }
local otherKeyPressed = { left = false, right = false }

shiftEventTap = hs.eventtap.new(
	{ hs.eventtap.event.types.flagsChanged, hs.eventtap.event.types.keyDown },
	function(event)
		local keyCode = event:getKeyCode()
		local flags = event:getFlags()

		if shiftKeyCodes[keyCode] then
			local side = shiftKeyCodes[keyCode]
			if event:getType() == hs.eventtap.event.types.flagsChanged then
				if not flags:contain({ "shift" }) then
					if shiftKeyDownTime[side] and not otherKeyPressed[side] then
						local duration = hs.timer.secondsSinceEpoch() - shiftKeyDownTime[side]
						if duration < tapDuration then
							if side == "left" then
								hs.keycodes.currentSourceID(englishInputSource)
							elseif side == "right" then
								hs.keycodes.currentSourceID(chineseInputSource)
							end
						end
					end
					shiftKeyDownTime[side] = nil
					otherKeyPressed[side] = nil
				else
					shiftKeyDownTime[side] = hs.timer.secondsSinceEpoch()
					otherKeyPressed[side] = false
				end
			end
		elseif shiftKeyDownTime.left or shiftKeyDownTime.right then
			otherKeyPressed.left = true
			otherKeyPressed.right = true
		end
		return false
	end
)

-- 启动事件监听
shiftEventTap:start()
