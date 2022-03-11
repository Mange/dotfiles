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
  ---
  --- Basics
  ---
  use "wbthomason/packer.nvim"
  use "jakelinnzy/autocmd-lua"
  use "DataWraith/auto_mkdir"
  use "tpope/vim-repeat"
  use "tpope/vim-speeddating"
  use "tpope/vim-surround"
  use "tpope/vim-eunuch" -- Adds things like :Move, :Rename, :SudoWrite, etc.
  use "tpope/vim-abolish" -- Smart S/re/repl/
  use "tommcdo/vim-exchange"

  use {
    "nathom/filetype.nvim",
    config = function()
      require "mange.plugin.filetypes"
    end,
  }

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
    requires = {
      -- Wants to hook into <CR> mappings set by cmp
      "hrsh7th/nvim-cmp",
    },
    config = function()
      require "mange.plugin.autopairs"
    end,
  }

  -- Strip trailing whitespace from modified lines only. Load before LSP so
  -- it's executed real early.
  use {
    "axelf4/vim-strip-trailing-whitespace",
    before = { "neovim/nvim-lspconfig" },
  }

  ---
  --- UI plugins
  ---
  -- Dashboard screen on Neovim boot
  use {
    "glepnir/dashboard-nvim",
    setup = function()
      vim.g.dashboard_default_executive = "telescope"
      vim.g.dashboard_custom_shortcut = {
        book_marks = "SPC h b",
        change_colorscheme = "SPC h c",
        find_file = "SPC s f",
        find_history = "SPC f h",
        find_word = "SPC s t",
        last_session = "SPC S l",
        new_file = "SPC b n",
      }
    end,
  }

  -- Statusline
  use {
    "hoob3rt/lualine.nvim",
    requires = { "kyazdani42/nvim-web-devicons", opt = true },
    config = function()
      require "mange.statusline"
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
          "vimwiki",
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
    requires = { "nvim-lua/plenary.nvim" },
    config = function()
      require "mange.plugin.telescope"
    end,
  }
  use {
    "nvim-telescope/telescope-file-browser.nvim",
    requires = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").load_extension "file_browser"
    end,
  }
  use {
    "nvim-telescope/telescope-fzf-native.nvim",
    run = "make",
    requires = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("telescope").load_extension "fzf"
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

  -- Icons; used by some other plugins
  use "kyazdani42/nvim-web-devicons"

  -- Show color previews
  -- Fork of norcalli/nvim-colorizer.lua
  -- See: https://github.com/norcalli/nvim-colorizer.lua/pull/55
  use {
    "DarwinSenior/nvim-colorizer.lua",
    config = function()
      -- Enable for all files and render as virtualtext
      require("colorizer").setup({ "*" }, {
        mode = "virtualtext",
      })
    end,
  }

  ---
  --- Git plugins
  ---
  use {
    "TimUntersberger/neogit",
    requires = {
      { "nvim-lua/plenary.nvim" },
      { "sindrets/diffview.nvim" },
    },
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
    requires = {
      "nvim-lua/plenary.nvim",
      "TimUntersberger/neogit",
    },
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
    requires = {
      { "nvim-lua/plenary.nvim" },
    },
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
    requires = { "jose-elias-alvarez/null-ls.nvim" },
    config = function()
      require "mange.lsp"
    end,
  }

  use "jose-elias-alvarez/null-ls.nvim"
  use {
    "liuchengxu/vista.vim",
    setup = function()
      vim.g.vista_sidebar_keepalt = 1
      vim.g.vista_echo_cursor_strategy = "floating_win"
      vim.g.vista_default_executive = "nvim_lsp"
      vim.g.vista_executive_for = {
        vimwiki = "markdown",
        pandoc = "markdown",
        markdown = "toc",
      }
    end,
  }

  use {
    "jose-elias-alvarez/nvim-lsp-ts-utils",
    requires = {
      "neovim/nvim-lspconfig",
      "nvim-lua/plenary.nvim",
      "jose-elias-alvarez/null-ls.nvim",
    },
  }

  use {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    requires = {
      { "JoosepAlviste/nvim-ts-context-commentstring" },
    },
    config = function()
      require "mange.treesitter"
    end,
  }

  use {
    "narutoxy/dim.lua",
    requires = { "nvim-treesitter/nvim-treesitter", "neovim/nvim-lspconfig" },
    config = function()
      require("dim").setup {}
    end,
  }

  ---
  --- Completion and snippets
  ---
  use {
    "dcampos/nvim-snippy",
    before = "hrsh7th/nvim-cmp",
    config = function()
      require("snippy").setup {}
    end,
  }

  -- Snippets collection. Might replace with my own later when I have time.
  use "honza/vim-snippets"

  use {
    "onsails/lspkind-nvim",
    config = function()
      require("lspkind").init()
    end,
  }

  use {
    "hrsh7th/nvim-cmp",
    requires = {
      "Saecki/crates.nvim",
      "dmitmel/cmp-cmdline-history",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-cmdline",
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
  use "JoosepAlviste/nvim-ts-context-commentstring"
  use "junegunn/vim-easy-align"

  -- Insert closing </tags> automatically in HTML-like filetypes.
  -- (Also handles renames of opening tag)
  use {
    "windwp/nvim-ts-autotag",
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
  use { "Saecki/crates.nvim", requires = { "nvim-lua/plenary.nvim" } }

  use {
    "simrat39/rust-tools.nvim",
    requires = { "nvim-lua/plenary.nvim" },
  }

  ---
  --- HTML, CSS, JS, TS, Webdev, etc.
  ---
  -- Automatically sort Tailwindcss classes.
  use {
    "steelsojka/headwind.nvim",
    config = function()
      require("headwind").setup {
        -- Using treesitter is a great idea, but it breaks in CSS using Postcss
        -- (@apply) and in ERB files (since it does not have an eruby
        -- treesitter config as of yet).
        -- Better to emulate the old stupid OG headwind way with a regexp for now.
        use_treesitter = false,
        class_regex = {
          eruby = {
            "class%s*[=:]%s*['\"]([_a-zA-Z0-9%s%-:/]+)['\"]",
            "class_names%s*[=:]%s*['\"]([_a-zA-Z0-9%s%-:/]+)['\"]",
            "class_name%s*[=:]%s*['\"]([_a-zA-Z0-9%s%-:/]+)['\"]",
            "classes%s*[=:]%s*['\"]([_a-zA-Z0-9%s%-:/]+)['\"]",
          },
        },
        -- TODO: Fork upstream to allow multiple places to look for the file in.
        -- https://github.com/steelsojka/headwind.nvim/blob/main/lua/headwind.lua#L308
      }
    end,
  }

  ---
  --- Vimwiki and Taskwarrior
  ---
  use {
    "vimwiki/vimwiki",
    setup = function()
      vim.g.vimwiki_global_ext = 0

      vim.g.vimwiki_key_mappings = {
        all_maps = 1,
        global = 0,
        headers = 1,
        text_objs = 1,
        table_format = 1,
        table_mappings = 1,
        lists = 1,
        links = 0, -- contains some <leader> mappings
        html = 0,
        mouse = 0,
      }

      vim.g.vimwiki_list = {
        {
          syntax = "markdown",
          ext = ".md",
          path = "~/Documents/Wiki/",
          template_path = "~/Documents/Wiki/templates/",
          html_template = "~/Documents/Wiki/html/",
          auto_tags = 1,
          auto_generate_links = 1,
          auto_generate_tags = 1,
          auto_toc = 1,
        },
      }

      -- Not supported by taskwiki
      -- https://github.com/tbabej/taskwiki/issues/119
      -- vim.g.vimwiki_listsyms = " ○◐●"
    end,
  }
  use {
    "blindFS/vim-taskwarrior",
    setup = function()
      vim.g.taskwiki_taskrc_location = "~/.config/taskwarrior/config"
      -- Will override my localleader unless disabled
      -- See https://github.com/tools-life/taskwiki/issues/362
      vim.g.taskwiki_suppress_mappings = true
    end,
  }
  use {
    "tbabej/taskwiki",
    requires = {
      "vimwiki/vimwiki",
      "tbabej/vim-taskwarrior",
    },
    run = "pip3 install --user --upgrade -r requirements.txt",
  }

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
