-- Basic plugins I wish was part of the default editor. No real GUI or anything...
return {
  { "nvim-lua/plenary.nvim" },
  { "nvim-tree/nvim-web-devicons", lazy = true },

  { "chrisgrieser/nvim-genghis" }, -- Convenience file operations
  { "direnv/direnv.vim" },
  { "DataWraith/auto_mkdir", lazy = false },

  {
    "klen/nvim-config-local",
    lazy = false,
    opts = {
      lookup_parents = true,
    },
  },
}
