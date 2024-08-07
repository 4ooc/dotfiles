require("modules/menubar")
-- NOTE: can't detect capslock evertytime

hs.hotkey.bind({ "command" }, "`", function()
  hs.application.launchOrFocus("/Applications/Alacritty.app")
end)
