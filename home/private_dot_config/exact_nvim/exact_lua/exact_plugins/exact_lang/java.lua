return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				lemminx = {
					settings = {
						xml = {
							server = {
								workDir = "~/.cache/lemminx",
							},
						},
					},
				},
			},
		},
	},

	{
		"mfussenegger/nvim-jdtls",
		opts = function(_, opts)
			local candidatesDir = os.getenv("SDKMAN_CANDIDATES_DIR")
			local jdk = candidatesDir .. "/java/21.0.10.fx-zulu"
			opts.cmd = vim.list_extend({ "env", "JAVA_HOME=" .. jdk }, opts.cmd)
			opts.settings = vim.list_extend({
				java = {
					configuration = {
						maven = {
							globalSettings = "~/.config/maven/settings.xml",
						},
					},
				},
			}, opts.settings)
		end,
	},
}
