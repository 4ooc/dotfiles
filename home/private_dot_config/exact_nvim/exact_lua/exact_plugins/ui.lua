return {
  {
    "lukas-reineke/indent-blankline.nvim",
    opts = {
      indent = {
        highlight = {
          "CursorColumn",
          "Whitespace",
        },
        char = ""
      },
      whitespace = {
        highlight = {
          "CursorColumn",
          "Whitespace",
        },
        remove_blankline_trail = false,
      },
      scope = { enabled = false },
      exclude = {
        filetypes = {
          "Trouble",
          "alpha",
          "dashboard",
          "help",
          "lazy",
          "lspinfo",
          "mason",
          "neo-tree",
          "terminal",
        },
      },
    },
    config = function(_, opts)
      require("ibl").setup(opts)
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
