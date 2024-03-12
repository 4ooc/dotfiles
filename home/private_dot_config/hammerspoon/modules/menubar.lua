local hs     = hs

local menu   = {}
local obj    = {}
menu.menubar = hs.menubar.new()
menu.canvas  = hs.canvas.new({ x = 0, y = 0, w = 24, h = 20 })
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

function menu:setMenubarTitle()
  local index = 1
  local width = 24
  self.canvas[index] = {
    type = "text",
    text = obj.pctBetify[1],
    textSize = obj.pctBetify[2],
    textFont = "Delugia Mono",
    textAlignment = "center",
    trackMouseEnterExit = true,
    frame = { x = 0, y = obj.pctBetify[3], w = 24, h = 20 - obj.pctBetify[3] }
  }
  index = index + 1

  if obj.isCharging then
    if obj.isAC and self.canvas[index] == nil then
      self.canvas[index] = {
        type = "rectangle",
        action = "stroke",
        strokeWidth = 1,
        roundedRectRadii = { xRadius = 0, yRadius = 0 },
        frame = { x = 0, y = 19, w = width, h = 1 }
      }
      index = index + 1
    end
  else
    if self.canvas[index] ~= nil then
      self.canvas:removeElement(index)
    end
  end

  self.canvas:size({ x = 0, y = 0, w = width, h = 20 })
  self.menubar:setIcon(self.canvas:imageFromCanvas())
end

local empty_letters = { "𝟘", "𝟙", "𝟚", "𝟛", "𝟜", "𝟝", "𝟞", "𝟟", "𝟠", "𝟡" }
local fill_letters  = { "𝟎", "𝟏", "𝟐", "𝟑", "𝟒", "𝟓", "𝟔", "𝟕", "𝟖", "𝟗" }
local function pctBetify()
  local letters = obj.hasNetwork and fill_letters or empty_letters
  local pct = obj.pct
  if pct == 100 then
    if obj.isCharging or not obj.isAC then
      return { "", 30, -7 }
    else
      return { "󰙴", 30, -7 }
    end
  else
    local _pct = ""
    local index = 0
    while pct >= 1 do
      index = (pct % 10) + 1
      index, _ = math.modf(index)
      _pct = letters[index] .. _pct
      pct = pct / 10
    end
    return { _pct, 20, obj.isAC and -3 or -2.5 }
  end
end

function menu:reset_menubar_if_changed()
  local batt_info = hs.battery.getAll()

  local pct = batt_info.percentage
  local isAC = batt_info.powerSource == "AC Power"
  local isCharging = batt_info.isCharging
  local hasNetwork = hs.wifi.currentNetwork() ~= nil

  if pct == obj.pct and isAC == obj.isAC and hasNetwork == obj.hasNetwork and isCharging == obj.isCharging then
    return
  end

  print("Current Percentage:", pct)

  obj.pct = pct
  obj.isAC = isAC
  obj.isCharging = isCharging
  obj.hasNetwork = hasNetwork
  obj.pctBetify = pctBetify()

  menu:setMenubarTitle()
end

-- battery watch
bw = hs.battery.watcher.new(function()
  menu:reset_menubar_if_changed()
end):start()

ww = hs.wifi.watcher.new(function()
  menu:reset_menubar_if_changed()
end):start()

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
  if event_type == hcw.screensaverDidStart or event_type == hcw.screensDidLock then
    bw:stop()
    ww:stop()
  elseif event_type == hcw.screensDidUnlock then
    bw:start()
    ww:start()
  end
end):start()

menu:reset_menubar_if_changed()
