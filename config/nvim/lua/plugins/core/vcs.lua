return {
  {
    "TimUntersberger/neogit",
    branch = "master",
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
    "algmyr/vcsigns.nvim",
    dependencies = {
      "algmyr/vclib.nvim",
      "lewis6991/async.nvim",
    },
    opts = {},
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
