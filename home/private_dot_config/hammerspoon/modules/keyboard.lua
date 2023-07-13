local M = {}

M._changeIME = 0
M._isCaps = nil

local eventtap = hs.eventtap
local keycodes = hs.keycodes
local types = eventtap.event.types
local rawFlags = eventtap.event.rawFlagMasks

M.keyDownEvent = eventtap.new(
  { types.keyDown },
  function()
    M._changeIME = 2
    M.keyDownEvent:stop()
  end
)

M.flagsChangedEvent = eventtap.new(
  { types.flagsChanged },
  function(event)
    local flags = event:rawFlags()
    local keyCode = event:getKeyCode()

    if (flags == 256 or flags == 65792) then
      if keyCode == 56 and M._changeIME == 1 then
        hs.hid.capslock.set(false)
        keycodes.currentSourceID("com.apple.keylayout.ABC")
      elseif keyCode == 60 and M._changeIME == 1 then
        hs.hid.capslock.set(false)
        keycodes.currentSourceID("com.apple.inputmethod.SCIM.Shuangpin")
      elseif keyCode == 57 then
        keycodes.currentSourceID("com.apple.keylayout.ABC")
        hs.hid.capslock.toggle()
        return true
      else
        M.keyDownEvent:stop()
      end
      M._changeIME = 0
    elseif (flags & 8319 & (~rawFlags.deviceLeftShift)) == 0 then
      if keyCode == 56 then
        M._changeIME = 1
        M.keyDownEvent:start()
      else
        M._changeIME = 2
        M.keyDownEvent:stop()
      end
    elseif (flags & 8319 & (~rawFlags.deviceRightShift)) == 0 then
      if keyCode == 60 then
        M._changeIME = 1
        M.keyDownEvent:start()
      else
        M._changeIME = 2
        M.keyDownEvent:stop()
      end
    end
  end
)

M.flagsChangedEvent:start()
