hs.hotkey.bind({ "option" }, "`", function()
	local alacritty = hs.application.get("com.mitchellh.ghostty")
	if alacritty == nil then
		hs.application.launchOrFocus("/Applications/Ghostty.app")
	else
		if alacritty:isFrontmost() then
			alacritty:hide()
		else
			alacritty:activate()
		end
	end
end)
