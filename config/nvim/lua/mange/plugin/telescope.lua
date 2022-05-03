local actions = require "telescope.actions"
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
}
