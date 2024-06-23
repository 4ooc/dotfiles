return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "beautysh",
        "black",
        "pyright",
        "shfmt",
        "typescript-language-server",
      }
    }
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lemminx = {
          settings = {
            xml = {
              server = {
                workDir = "~/.cache/lemminx",
              }
            }
          }
        }
      }
    },
  },

  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      local null_ls = require("null-ls")
      local formatting = null_ls.builtins.formatting

      opts.sources = {
        formatting.black,
        formatting.shfmt.with({
          extra_args = function()
            return { "-ci", "-s", "-sr", "-i", (vim.bo.expandtab and vim.bo.tabstop or 0) }
          end,
          filetypes = { "bash", "sh", "zsh" },
        }),
      }
    end,
  },
}
