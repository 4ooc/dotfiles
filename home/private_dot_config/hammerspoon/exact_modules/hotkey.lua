local M = {}

M.ghosttyToggle = hs.hotkey.bind({ "option" }, "`", function()
	local ghostty = hs.application.get("com.mitchellh.ghostty")
	if ghostty == nil then
		hs.application.launchOrFocus("/Applications/Ghostty.app")
		return
	end

	if ghostty:isFrontmost() then
		ghostty:hide()
	else
		ghostty:activate()
	end
end)

return M
