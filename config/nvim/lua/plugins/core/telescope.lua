return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
    },
    config = function()
      local telescope = require "telescope"
      local actions = require "telescope.actions"

      telescope.setup {
        defaults = {
          mappings = {
            i = {
              ["<C-j>"] = actions.cycle_history_next,
              ["<C-k>"] = actions.cycle_history_prev,
              ["<C-n>"] = actions.cycle_history_next,
              ["<C-p>"] = actions.cycle_history_prev,
              ["<C-q>"] = function(...)
                actions.smart_send_to_qflist(...)
                require("trouble").open { mode = "quickfix", focus = true }
              end,
            },
          },
        },
      }

      telescope.load_extension "fzf"
    end,
  },
}
