require("modules/menubar")

hs.hotkey.bind({ "option" }, "`", function()
  local alacritty = hs.application.get("org.alacritty")
  if alacritty == nil then
    hs.application.launchOrFocus("/Applications/Alacritty.app")
  else
    if alacritty:isFrontmost() then
      alacritty:hide()
    else
      alacritty:activate()
    end
  end
end)
