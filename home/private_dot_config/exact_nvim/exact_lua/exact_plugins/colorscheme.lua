return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "onedark"
    }
  },

  {
    "navarasu/onedark.nvim",
    lazy = false,
    opts = {
      style = 'deep',
      transparent = true,

      highlights = {
        NotifyBackground = { bg = "#ffffff" },
      }
    }
  },
}
