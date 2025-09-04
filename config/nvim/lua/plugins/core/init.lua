-- Basic plugins I wish was part of the default editor. No real GUI or anything...
return {
  { "nvim-lua/plenary.nvim" }, -- Support library
  { "nvim-tree/nvim-web-devicons", lazy = true }, -- Icons

  -- Convenience file operations
  {
    "chrisgrieser/nvim-genghis",
    opts = { fileOperations = { autoAddExt = false } },
  },

  -- Support for project-local configs.
  { "direnv/direnv.vim", lazy = false },
  { "klen/nvim-config-local", lazy = false, opts = { lookup_parents = true } },
}
