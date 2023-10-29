-- Basic plugins I wish was part of the default editor. No real GUI or anything...
return {
  { "DataWraith/auto_mkdir", lazy = false },

  { "nvim-lua/plenary.nvim" },
  { "direnv/direnv.vim" },

  { "tpope/vim-eunuch", event = "VeryLazy" }, -- Adds things like :Move, :Rename, :SudoWrite, etc.
}
