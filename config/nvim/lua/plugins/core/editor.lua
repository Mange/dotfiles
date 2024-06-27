return {
  {
    "kylechui/nvim-surround",
    opts = {},
    event = "InsertEnter",
  },

  { "gbprod/substitute.nvim", opts = {} },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        search = { enabled = false },
        char = { enabled = false },
      },
      label = {
        rainbow = { enabled = true },
      },
    },
  },

  {
    "johmsalas/text-case.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    opts = {
      default_keymappings_enabled = true,
      -- From tpope/vim-abolish; since it's hard to retrain muscle memory.
      prefix = "cr", -- mnemonic "coerce"
      substitude_command_name = "S",
    },
    config = function(_, opts)
      require("textcase").setup(opts)
      require("telescope").load_extension "textcase"
    end,
  },

  {
    "junegunn/vim-easy-align",
    cmd = { "EasyAlign", "LiveEasyAlign" },
    event = "InsertEnter",
  },

  -- Show lightbulbs when code actions are available on the current line
  {
    "kosayoda/nvim-lightbulb",
    opts = {
      autocmd = { enabled = true },
      hide_in_unfocused_buffer = true,
      sign = { enabled = false },
      virtual_text = { enabled = true, text = "  " },
      action_kinds = {
        "quickfix",
        "refactor",
        "refactor.extract",
        "refactor.inline",
        "refactor.rewrite",
        -- "source",
        -- "source.organizeImports",
        -- "source.fixAll",
      },
    },
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
