return {
  {
    "github/copilot.vim",
    event = "InsertEnter",
    init = function()
      vim.g.copilot_node_command =
        "/home/mange/.local/share/nvm/versions/node/v16.19.0/bin/node"
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_filetypes = { eruby = false }
      -- Mapping set up in mappings.lua
    end,
  },
}
