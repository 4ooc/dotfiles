if not vim.filetype then
	return
end

vim.filetype.add({
	pattern = {
		[".*/%.?git/.*%.?config"] = "gitconfig",
	},
})
