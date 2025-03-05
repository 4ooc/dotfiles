return {
  {
    "rcarriga/nvim-notify",
    opts = {
      fps = 120,
      render = "wrapped-compact",
      stages = "fade_in_slide_out",
      top_down = false,
    },
  },

  {
    "norcalli/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup()
    end,
  },
}
