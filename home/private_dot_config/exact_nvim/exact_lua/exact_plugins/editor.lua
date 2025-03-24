return {
  {
    "folke/which-key.nvim",
    opts = {
      preset = "helix",
      plugins = {
        marks = true,
        registers = true,
        spelling = {
          enabled = true,
          suggestions = 20,
        },
      },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        group_empty_dirs = true,
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
        },
      },
      event_handlers = {
        {
          event = "neo_tree_buffer_enter",
          handler = function()
            vim.cmd([[
              setlocal relativenumber
            ]])
          end,
        },
      },
      source_selector = {
        winbar = true,
      },
      window = { width = 42 },
    },
  },
}
