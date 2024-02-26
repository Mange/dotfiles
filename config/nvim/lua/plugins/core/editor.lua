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

  -- Show lightbulbs when code actions are available on the current line
  {
    "kosayoda/nvim-lightbulb",
    opts = { autocmd = { enabled = true } },
  },

  -- Indentation guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = {
        char = "▏",
      },
      scope = {
        char = "┇",
        show_start = false,
      },
    },
  },

  -- Dim unused variables
  { "narutoxy/dim.lua", opts = {} },

  {
    "Wansmer/treesj",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      use_default_keymaps = false,
      check_syntax_error = true,
      max_join_length = 1000,
      cursor_behavior = "hold",
      notify = true, -- notify on errors
    },
  },

  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true,
    opts = { enable_autocmd = false },
  },
  {
    "terrortylor/nvim-comment",
    event = "VeryLazy",
    config = function()
      require("nvim_comment").setup {
        hook = function()
          require("ts_context_commentstring.internal").update_commentstring()
        end,
      }
    end,
  },
}