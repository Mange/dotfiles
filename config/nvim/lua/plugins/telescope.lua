local function config()
  local telescope = require "telescope"
  local actions = telescope.actions
  local fb_actions = telescope.extensions.file_browser.actions

  local has_trouble, trouble = pcall(require, "trouble.providers.telescope")

  local all_to_qf
  if has_trouble then
    all_to_qf = trouble.open_with_trouble
  else
    all_to_qf = actions.send_to_qflist
  end

  require("telescope").setup {
    defaults = {
      mappings = {
        i = {
          ["<C-j>"] = require("telescope.actions").cycle_history_next,
          ["<C-k>"] = require("telescope.actions").cycle_history_prev,
          ["<C-n>"] = require("telescope.actions").cycle_history_next,
          ["<C-p>"] = require("telescope.actions").cycle_history_prev,
          ["<C-q>"] = all_to_qf,
        },
      },
    },

    extensions = {
      file_browser = {
        theme = "ivy",

        -- disables netrw and use telescope-file-browser in its place
        hijack_netrw = true,

        mappings = {
          ["i"] = {
            ["<C-w>"] = { "<c-s-w>", type = "command" },
            ["<C-h>"] = fb_actions.goto_cwd,
          },
        },
      },
    },
  }

  require("telescope").load_extension "file_browser"
  require("telescope").load_extension "fzf"
end

return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-file-browser.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
    },
    config = config,
  },
}
