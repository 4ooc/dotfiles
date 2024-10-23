return {
  {
    "zdharma-continuum/zinit-vim-syntax",
    ft = { "zsh", "zsh.chezmoitmpl" },
    event = "VeryLazy",
  },

  {
    "alker0/chezmoi.vim",
    lazy = false,
    init = function()
      vim.g["chezmoi#use_tmp_buffer"] = true
    end,
  },
}
