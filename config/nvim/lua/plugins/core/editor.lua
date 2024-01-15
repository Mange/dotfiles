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

  -- Replace with a lua implementation?
  {
    "AndrewRadev/splitjoin.vim",
    event = "InsertEnter",
    init = function()
      vim.g.splitjoin_ruby_curly_braces = 0
      vim.g.splitjoin_ruby_hanging_args = 0 -- I am not insane
      vim.g.splitjoin_ruby_options_as_arguments = 1

      vim.g.splitjoin_ruby_trailing_comma = 0 -- standardrb does not like
      vim.g.splitjoin_trailing_comma = 1 -- …but I do

      vim.g.splitjoin_html_attributes_bracket_on_new_line = 1

      -- Setup in mange.mappings
      vim.g.splitjoin_split_mapping = ""
      vim.g.splitjoin_join_mapping = ""
    end,
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
