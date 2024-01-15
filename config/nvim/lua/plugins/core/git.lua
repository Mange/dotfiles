return {
  {
    "TimUntersberger/neogit",
    opts = {
      -- I want to start in insert mode on empty commit messages.
      disable_insert_on_commit = false,

      -- Nicer characters
      signs = {
        section = { "▶", "▼" },
        item = { "▶", "▼" },
        hunk = { "▶", "▼" },
      },

      integrations = {
        telescope = true,
        diffview = true,
      },
    },
  },

  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "┃" },
        change = { text = "╏" },
        delete = { text = "┋" },
        topdelete = { text = "┋" },
        changedelete = { text = "┋" },
      },
    },
  },

  {
    "sindrets/diffview.nvim",
    opts = {
      key_bindings = {
        view = {
          ["q"] = "<cmd>DiffviewClose<cr>",
        },
        file_panel = {
          ["q"] = "<cmd>DiffviewClose<cr>",
        },
        file_history_panel = {
          ["q"] = "<cmd>DiffviewClose<cr>",
        },
      },
    },
  },
}
