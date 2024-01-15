return {
  {
    "github/copilot.vim",
    event = "InsertEnter",
    init = function()
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_filetypes = { eruby = false }
      vim.g.copilot_assume_mapped = true
      -- Mapping set up in mappings.lua
    end,
  },
}
