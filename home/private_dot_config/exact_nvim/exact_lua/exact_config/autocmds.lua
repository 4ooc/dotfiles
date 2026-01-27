-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
	callback = function()
		vim.opt.relativenumber = true
		vim.wo.cursorline = true
	end,
})
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
	callback = function()
		vim.opt.relativenumber = false
		vim.wo.cursorline = false
	end,
})

if not require("lazy.core.config").plugins["editorconfig"] then
	local tab_settings = {
		-- filetype = spaces
		zsh = 2,
	}
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "*",
		callback = function(args)
			local ft = args.match
			local spaces = tab_settings[ft]
			if spaces then
				vim.bo.tabstop = spaces
				vim.bo.shiftwidth = spaces
				vim.bo.expandtab = true
			end
		end,
	})
end
