return {
  {
    "TimUntersberger/neogit",
    opts = {
      -- I know what I'm doing
      disable_commit_confirmation = true,

      -- Nicer characters
      signs = {
        section = { "▶", "▼" },
        item = { "▶", "▼" },
        hunk = { "▶", "▼" },
      },

      mappings = {
        status = {
          -- I use L to go to next tab; use "M" as in "commit MESSAGES"
          -- instead.
          ["L"] = "",
          ["m"] = "LogPopup",
        },
      },

      integrations = {
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
