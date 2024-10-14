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
      local handle = io.popen("mise where java@17")
      local jdk17 = ""
      if handle ~= nil then
        jdk17 = handle:read("*a")
        jdk17 = string.gsub(jdk17, "\n", "")
        handle:close()
      end

      if jdk17 == "" then
        LazyVim.warn("Can't run `mise where java@17`")
        return
      end

      opts.cmd = vim.list_extend({ "env", "JAVA_HOME=" .. jdk17 }, opts.cmd)
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
