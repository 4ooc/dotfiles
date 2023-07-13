return {
  {
    "lukas-reineke/indent-blankline.nvim",
    opts = {
      char = "│",
      filetype_exclude = {
        "Trouble",
        "alpha",
        "dashboard",
        "help",
        "lazy",
        "lspinfo",
        "mason",
        "neo-tree",
        "terminal",
        "",
      },
      buftype_exclude = { "terminal" },
      show_current_context = true,
      show_current_context_start = true,
    },
    config = function(_, opts)
      vim.cmd [[ highlight IndentBlanklineContextStart guibg=#12415d gui=nocombine ]]
      require("indent_blankline").setup(opts)
    end
  },

  {
    "rcarriga/nvim-notify",
    opts = function(_, opts)
      opts.stages = "fade_in_slide_out"
      opts.top_down = false
    end
  },

  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
  },
}
