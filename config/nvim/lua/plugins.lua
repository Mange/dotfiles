--
--              ███████   ██                 ██
--             ░██░░░░██ ░██          █████ ░░
--             ░██   ░██ ░██ ██   ██ ██░░░██ ██ ███████   ██████
--             ░███████  ░██░██  ░██░██  ░██░██░░██░░░██ ██░░░░
--             ░██░░░░   ░██░██  ░██░░██████░██ ░██  ░██░░█████
--             ░██       ░██░██  ░██ ░░░░░██░██ ░██  ░██ ░░░░░██
--             ░██       ███░░██████  █████ ░██ ███  ░██ ██████
--             ░░       ░░░  ░░░░░░  ░░░░░  ░░ ░░░   ░░ ░░░░░░
--

require("packer").startup(function(use)
  local plenary = "nvim-lua/plenary.nvim"
  local devicons = "nvim-tree/nvim-web-devicons"

  ---
  --- Basics
  ---
  use "wbthomason/packer.nvim"
  use "jakelinnzy/autocmd-lua"
  use "DataWraith/auto_mkdir"
  use "tpope/vim-repeat"
  use "tpope/vim-speeddating"
  use "tpope/vim-eunuch" -- Adds things like :Move, :Rename, :SudoWrite, etc.
  use "tpope/vim-abolish" -- Smart S/re/repl/
  use "tommcdo/vim-exchange"
  use "ggandor/leap.nvim"

  use {
    "kylechui/nvim-surround",
    config = function()
      require("nvim-surround").setup()
    end,
  }

  use { "antoinemadec/FixCursorHold.nvim" }

  use {
    "AndrewRadev/switch.vim",
    setup = function()
      vim.g.switch_mapping = "" -- Setup in mange.mappings
    end,
  }

  use {
    "AndrewRadev/splitjoin.vim",
    setup = function()
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
  }

  use {
    "windwp/nvim-autopairs",
    after = {
      -- Wants to hook into <CR> mappings set by cmp
      "cmp",
    },
    config = function()
      require "mange.plugin.autopairs"
    end,
  }

  -- Better folds
  use {
    "kevinhwang91/nvim-ufo",
    requires = "kevinhwang91/promise-async",
    before = { "lspconfig" },
    config = function()
      require "mange.plugin.folds"
    end,
  }

  ---
  --- UI plugins
  ---
  -- Statusline
  use {
    "hoob3rt/lualine.nvim",
    requires = { devicons },
    config = function()
      require "mange.statusline"
    end,
  }

  -- Focus mode
  use {
    -- "Pocco81/true-zen.nvim",
    "loqusion/true-zen.nvim",
    config = function()
      require("true-zen").setup {
        modes = {
          narrow = {
            folds_style = "invisible",
          },
          minimalist = {
            options = {
              list = false, -- hide listchars
            },
          },
        },
      }
    end,
  }

  use {
    "lukas-reineke/indent-blankline.nvim",
    config = function()
      require("indent_blankline").setup {
        space_char_blankline = " ",
        show_current_context = true,
        buftype_exclude = {
          "terminal",
          "prompt",
          "quickfix",
          "nofile",
          "help",
        },
        filetype_exclude = {
          "TelescopePrompt",
          "dashboard",
          "help",
          "man",
          "markdown",
          "text",
        },
        context_patterns = {
          "^if",
          "^table",
          "block",
          "class",
          "for",
          "function",
          "if_statement",
          "list_literal",
          "method",
          "selector",
          "while",
        },
        show_first_indent_level = false,
        show_end_of_line = false,
        use_treesitter = true,
      }
    end,
  }

  -- Finder
  use {
    "nvim-telescope/telescope.nvim",
    as = "telescope",
    requires = {
      plenary,
      "nvim-telescope/telescope-file-browser.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        run = "make",
      },
    },
    config = function()
      require "mange.plugin.telescope"
    end,
  }

  use {
    "stevearc/dressing.nvim",
    config = function()
      require "mange.plugin.dressing"
    end,
  }

  -- Colortheme
  use { "catppuccin/nvim", as = "catppuccin" }

  -- Show keybinds while waiting for the next key. Allows more complicated
  -- keybinds to be remembered.
  use {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup()
    end,
  }

  -- Show color previews
  -- Fork of norcalli/nvim-colorizer.lua
  -- See: https://github.com/norcalli/nvim-colorizer.lua/pull/55
  use {
    "DarwinSenior/nvim-colorizer.lua",
    config = function()
      -- Enable for all files not covered by color-capable LSPs and render as
      -- virtualtext.
      require("colorizer").setup({ "*", "!tsx", "!css", "!html" }, {
        mode = "virtualtext",
      })
    end,
  }

  use {
    "kosayoda/nvim-lightbulb",
    requires = { "antoinemadec/FixCursorHold.nvim" },
    config = function()
      require("nvim-lightbulb").setup { autocmd = { enabled = true } }
    end,
  }

  ---
  --- Git plugins
  ---
  use {
    "TimUntersberger/neogit",
    as = "neogit",
    requires = { plenary },
    before = { "diffview" },

    config = function()
      require("neogit").setup {
        -- I know what I'm doing
        disable_commit_confirmation = true,

        -- Nicer characters
        signs = {
          section = { "▶", "▼" },
          item = { "▶", "▼" },
          hunk = { "▶", "▼" },
        },

        mappings = {
          status = {
            -- I use L to go to next tab; use "M" as in "commit MESSAGES"
            -- instead.
            ["L"] = "",
            ["m"] = "LogPopup",
          },
        },

        integrations = {
          diffview = true,
        },
      }
    end,
  }

  use {
    "lewis6991/gitsigns.nvim",
    requires = { plenary },
    after = { "neogit" },
    config = function()
      require("gitsigns").setup {
        signs = {
          add = { text = "┃" },
          change = { text = "╏" },
          delete = { text = "┋" },
          topdelete = { text = "┋" },
          changedelete = { text = "┋" },
        },
      }
    end,
  }

  use {
    "sindrets/diffview.nvim",
    as = "diffview",
    requires = { plenary },
    config = function()
      require("diffview").setup {
        key_bindings = {
          view = {
            ["q"] = "<cmd>DiffviewClose<cr>",
          },
          file_panel = {
            ["q"] = "<cmd>DiffviewClose<cr>",
          },
          file_history_panel = {
            ["q"] = "<cmd>DiffviewClose<cr>",
          },
        },
      }
    end,
  }

  ---
  --- LSP and Treesitter
  ---
  use {
    "neovim/nvim-lspconfig",
    as = "lspconfig",
    config = function()
      require "mange.lsp"
    end,
  }

  use {
    "jose-elias-alvarez/null-ls.nvim",
    as = "null-ls",
    before = { "lspconfig" },
  }
  use {
    "lukas-reineke/lsp-format.nvim",
    before = { "lspconfig" },
  }

  use {
    "lvimuser/lsp-inlayhints.nvim",
    before = { "lspconfig" },
    config = function()
      require("lsp-inlayhints").setup {
        inlay_hints = {
          type_hints = {
            prefix = "  ",
            remove_colon_start = true,
          },
          parameter_hints = {
            prefix = "",
          },
        },
        labels_separator = "",
      }
    end,
  }

  use {
    "mrshmllow/document-color.nvim",
    before = { "lspconfig" },
    config = function()
      require("document-color").setup {
        mode = "single",
      }
    end,
  }

  use {
    "SmiteshP/nvim-navic",
    before = { "lspconfig" },
    config = function()
      require("nvim-navic").setup {
        highlight = true,
        separator = "  ",
        icons = {
          File = " ",
          Module = " ",
          Namespace = " ",
          Package = " ",
          Class = " ",
          Method = " ",
          Property = " ",
          Field = " ",
          Constructor = " ",
          Enum = " ",
          Interface = " ",
          Function = " ",
          Variable = " ",
          Constant = " ",
          String = " ",
          Number = " ",
          Boolean = " ",
          Array = " ",
          Object = " ",
          Key = " ",
          Null = " ",
          EnumMember = " ",
          Struct = " ",
          Event = " ",
          Operator = " ",
          TypeParameter = " ",
        },
      }
    end,
  }

  use {
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",
    after = { "lspconfig" },
    config = function()
      require("lsp_lines").setup()
    end,
  }

  use {
    "onsails/lspkind-nvim",
    config = function()
      require("lspkind").init()
    end,
  }

  use {
    -- Use fork with this PR implemented:
    --   https://github.com/simrat39/symbols-outline.nvim/pull/169
    -- "simrat39/symbols-outline.nvim",
    "mxsdev/symbols-outline.nvim",
    branch = "merge-jsx-tree",
    as = "symbols-outline",
    config = function()
      require("symbols-outline").setup {
        lsp_blacklist = {},
        symbol_blacklist = {
          -- 'File',
          -- 'Module',
          -- 'Namespace',
          -- 'Package',
          -- 'Class',
          -- 'Method',
          -- 'Property',
          -- 'Field',
          -- 'Constructor',
          -- 'Enum',
          -- 'Interface',
          -- 'Function',
          -- 'Variable',
          -- 'Constant',
          -- 'String',
          -- 'Number',
          -- 'Boolean',
          -- 'Array',
          -- 'Object',
          -- 'Key',
          -- 'Null',
          -- 'EnumMember',
          -- 'Struct',
          -- 'Event',
          -- 'Operator',
          -- 'TypeParameter',
        },
        winblend = 20,
      }
    end,
  }

  use {
    "folke/trouble.nvim",
    requires = { devicons },
    config = function()
      require("trouble").setup {}
    end,
  }

  use {
    "nvim-treesitter/nvim-treesitter",
    as = "treesitter",
    run = ":TSUpdate",
    config = function()
      require "mange.treesitter"
    end,
  }

  use {
    "narutoxy/dim.lua",
    after = { "treesitter", "lspconfig" },
    config = function()
      require("dim").setup {}
    end,
  }

  ---
  --- Completion and snippets
  ---
  use {
    "dcampos/nvim-snippy",
    before = { "cmp", "dcampos/cmp-snippy" },
    config = function()
      require("snippy").setup {}
    end,
  }

  -- Snippets collection. Might replace with my own later when I have time.
  use "honza/vim-snippets"

  use {
    "github/copilot.vim",
    config = function()
      vim.g.copilot_node_command =
        "/home/mange/.local/share/nvm/versions/node/v16.19.0/bin/node"
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_filetypes = { eruby = false }
      -- Mapping set up in mappings.lua
    end,
  }

  use {
    "hrsh7th/nvim-cmp",
    as = "cmp",
    requires = {
      "Saecki/crates.nvim",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-path",
      "onsails/lspkind-nvim",
      "ray-x/cmp-treesitter",
      "dcampos/cmp-snippy",
      "simrat39/rust-tools.nvim",
    },
    config = function()
      require("mange.plugin.cmp").setup()
    end,
  }

  ---
  --- Coding
  ---
  use { "JoosepAlviste/nvim-ts-context-commentstring", after = { "treesitter" } }
  use "junegunn/vim-easy-align"

  -- Insert closing </tags> automatically in HTML-like filetypes.
  -- (Also handles renames of opening tag)
  use {
    "windwp/nvim-ts-autotag",
    after = { "lspconfig", "treesitter" },
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  }

  use {
    "terrortylor/nvim-comment",
    config = function()
      require("nvim_comment").setup {
        hook = function()
          if_require("ts_context_commentstring.internal", function(module)
            module.update_commentstring()
          end)
        end,
      }
    end,
  }

  -- Mainly for navigation commands like `:A`
  use "tpope/vim-rails"
  -- …and let's add support for `:A` in other project types.
  -- (Not possible to get full fidelity for Rails apps with just projectionist)
  use {
    "tpope/vim-projectionist",
    setup = function()
      require "mange.plugin.projectionist"
    end,
  }

  ---
  --- Rust
  ---
  use { "Saecki/crates.nvim", requires = { plenary } }

  use {
    "simrat39/rust-tools.nvim",
    requires = { plenary },
    before = { "lvimuser/lsp-inlayhints.nvim", "lspconfig" },
  }

  ---
  --- HTML, CSS, JS, TS, Webdev, etc.
  ---
  -- Automatically sort Tailwindcss classes.
  -- use {
  --   "steelsojka/headwind.nvim",
  --   config = function()
  --     require("headwind").setup {
  --       -- Using treesitter is a great idea, but it breaks in CSS using Postcss
  --       -- (@apply) and in ERB files (since it does not have an eruby
  --       -- treesitter config as of yet).
  --       -- Better to emulate the old stupid OG headwind way with a regexp for now.
  --       use_treesitter = false,
  --       class_regex = {
  --         eruby = {
  --           "class%s*[=:]%s*['\"]([_a-zA-Z0-9%s%-:/]+)['\"]",
  --           "class_names%s*[=:]%s*['\"]([_a-zA-Z0-9%s%-:/]+)['\"]",
  --           "class_name%s*[=:]%s*['\"]([_a-zA-Z0-9%s%-:/]+)['\"]",
  --           "classes%s*[=:]%s*['\"]([_a-zA-Z0-9%s%-:/]+)['\"]",
  --         },
  --       },
  --       -- TODO: Fork upstream to allow multiple places to look for the file in.
  --       -- https://github.com/steelsojka/headwind.nvim/blob/main/lua/headwind.lua#L308
  --     }
  --   end,
  -- }

  ---
  --- Others
  ---
  use "towolf/vim-helm"

  ---
  --- External tools
  ---
  use {
    "glacambre/firenvim",
    run = function()
      vim.fn["firenvim#install"](0)
    end,
    setup = function()
      vim.g.firenvim_config = {
        globalSettings = {
          alt = "all",
        },
        localSettings = {
          [".*"] = {
            cmdline = "neovim",
            content = "text",
            priority = 0,
            selector = "textarea",
            takeover = "never",
          },
        },
      }
    end,
  }
end)
