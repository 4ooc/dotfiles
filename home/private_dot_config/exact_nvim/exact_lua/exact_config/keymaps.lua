-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local delmap = function(modes, lhs, opts)
	vim.keymap.del(modes, lhs, opts)
end

delmap("n", "<leader>ft")
delmap({ "n", "t" }, "<c-/>")
delmap({ "n", "t" }, "<c-_>")

vim.cmd("ono w iw")

vim.api.nvim_create_user_command("W", function()
  local filepath = vim.fn.expand("%:p")
  vim.cmd(string.format("w !sudo tee %s > /dev/null", filepath))
end, {})
