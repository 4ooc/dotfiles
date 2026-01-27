-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.colorcolumn = "81"
vim.opt.expandtab = false
vim.opt.tabstop = 3
vim.opt.shiftwidth = 3
vim.opt.list = true
vim.opt.listchars = {
	tab = " ->",
	trail = "·",
	space = "␣",
}

vim.g.autoformat = false

-- vim.opt.guicursor = {
--  "n-v-r-cr:block-blinkwait175-blinkoff150-blinkon175",
--  "i-c-ci-ve:ver50",
--  "r-cr:MCursorReplace/lMCursorReplace",
--  "o:hor50-MCursorCommand/lMCursorCommand",
--  "c-ci:MCursorCommand/lMCursorCommand",
--  "i:blinkwait700-blinkoff400-blinkon250-MCursorInsert/lMCursorInsert",
--  "n:MCursorNormal/lMCursorNormal",
--  "v:MCursorVisual/lMCursorVisual",
--  "sm:block-blinkwait175-blinkoff150-blinkon175",
-- }

vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.breakindentopt:append({
	"shift:3",
})
