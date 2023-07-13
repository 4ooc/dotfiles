return {
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    config = function()
      require("Comment").setup()

      local ft = require("Comment.ft")
      ft({ "kdl" }, "//%s")
    end,
  },

  {
    "windwp/nvim-autopairs",
    config = "true",
  },
}
