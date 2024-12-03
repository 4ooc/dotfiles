require("modules/menubar")

hs.hotkey.bind({ "option" }, "`", function()
  local alacritty = hs.application.get("wezterm")
  if alacritty == nil then
    hs.application.launchOrFocus("/Applications/WezTerm.app")
  else
    if alacritty:isFrontmost() then
      alacritty:hide()
    else
      alacritty:activate()
    end
  end
end)
