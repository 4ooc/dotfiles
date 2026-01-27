return {
	{
		"folke/flash.nvim",
		opts = {
			search = {
				incremental = true,
			},
			modes = {
				char = {
					jump_labels = true,
				},
			},
		},
		keys = {
			{ "s", mode = { "n", "x", "o" }, false },
			{ "S", mode = { "n", "x", "o" }, false },
			{ "r", mode = { "o" }, false },
			{ "R", mode = { "o", "x" }, false },
			{ "<c-s>", mode = { "c" }, false },
		},
	},

	{
		"lewis6991/gitsigns.nvim",
		opts = {
			current_line_blame = true,
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
				delay = 300,
				ignore_whitespace = false,
			},
		},
	},

	{
		"akinsho/toggleterm.nvim",
		lazy = true,
		keys = {
			{ "<c-\\>" },
		},
		opts = {
			shade_terminals = false,
			open_mapping = [[<c-\>]],
			persist_mode = false,
			on_open = function()
				local opts = { buffer = 0 }
				vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts)
			end,
		},
	},

	{
		"willothy/flatten.nvim",
		opts = {
			hooks = {
				pre_open = function()
					-- Close toggleterm when an external open request is received
					require("toggleterm").toggle(0)
				end,
				post_open = function(bufnr, winnr, ft)
					if ft == "gitcommit" then
						-- If the file is a git commit, create one-shot autocmd to delete it on write
						-- If you just want the toggleable terminal integration, ignore this bit and only use the
						-- code in the else block
						vim.api.nvim_create_autocmd("BufWritePost", {
							buffer = bufnr,
							once = true,
							callback = function()
								-- This is a bit of a hack, but if you run bufdelete immediately
								-- the shell can occasionally freeze
								vim.defer_fn(function()
									vim.api.nvim_buf_delete(bufnr, {})
								end, 50)
							end,
						})
					else
						-- If it's a normal file, then reopen the terminal, then switch back to the newly opened window
						-- This gives the appearance of the window opening independently of the terminal
						vim.api.nvim_set_current_win(winnr)
					end
				end,
				block_end = function()
					-- After blocking ends (for a git commit, etc), reopen the terminal
					require("toggleterm").toggle(0)
				end,
			},
		},
	},
}
