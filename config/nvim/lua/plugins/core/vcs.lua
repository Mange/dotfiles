return {
  {
    "nicolasgb/jj.nvim",
    version = "*", -- Use latest stable release
    opts = {
      diff = {
        -- Diffview does not support non-colocated jj
        -- backend = "diffview",
        backend = "native",
      },
    },
  },
  {
    "algmyr/vcmarkers.nvim",
    dependencies = { "algmyr/vclib.nvim" },
    opts = {},
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
