require("modules/menubar")
-- NOTE: can't detect capslock evertytime

hs.hotkey.bind({ "command" }, "`", function()
  local alacritty = hs.application.find('org.alacritty')
  if alacritty ~= nil and alacritty:isFrontmost() then
    alacritty:hide()
  else
    hs.application.launchOrFocus("/Applications/Alacritty.app")
  end
end)
