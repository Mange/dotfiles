return {
  {
    "nicolasgb/jj.nvim",
    version = "*", -- Use latest stable release
    opts = {
      diff = {
        backend = "diffview",
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
    "dlyongemallo/diffview-plus.nvim",
    opts = {
      enhanced_diff_hl = true,
      diffopt = { algorithm = "histogram" },
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
