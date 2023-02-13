-- Basic plugins I wish was part of the default editor. No real GUI or anything...
return {
  { "DataWraith/auto_mkdir", lazy = false },

  { "nvim-lua/plenary.nvim" },

  { "tpope/vim-repeat", event = "VeryLazy" },
  { "tpope/vim-eunuch", event = "VeryLazy" }, -- Adds things like :Move, :Rename, :SudoWrite, etc.
  { "tpope/vim-abolish", cmd = "S", keys = { "cr" } }, -- Smart S/re/repl/
  { "tommcdo/vim-exchange", event = "VeryLazy" },

  { "ggandor/leap.nvim" },
}
