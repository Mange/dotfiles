return {
  {
    "kylechui/nvim-surround",
    opts = {},
    event = "InsertEnter",
  },

  { "ggandor/leap.nvim" },
  { "tpope/vim-repeat", event = "VeryLazy" },
  { "tommcdo/vim-exchange", event = "VeryLazy" },
  { "tpope/vim-abolish", cmd = "S", keys = { "cr" } }, -- Smart S/re/repl/

  {
    "junegunn/vim-easy-align",
    cmd = { "EasyAlign", "LiveEasyAlign" },
    event = "InsertEnter",
  },
}
