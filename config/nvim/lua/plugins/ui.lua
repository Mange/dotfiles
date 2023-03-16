local icons = require "config.icons"

return {
  -- Show keybinds while waiting for the next key. Allows more complicated
  -- keybinds to be remembered.
  {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup()
    end,
  },

  -- Support for icons
  {
    { "nvim-tree/nvim-web-devicons", lazy = true },
  },

  -- Better `vim.notify()`
  {
    "rcarriga/nvim-notify",
    lazy = false,
    opts = {
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
    },
    config = function()
      vim.notify = require("notify").notify
    end,
  },

  -- Better `vim.ui`
  {
    "stevearc/dressing.nvim",
    lazy = true,
    opts = {
      select = { backend = { "telescope", "builtin" } },
    },
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load { plugins = { "dressing.nvim" } }
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load { plugins = { "dressing.nvim" } }
        return vim.ui.input(...)
      end
    end,
  },

  -- Dim unused variables
  { "narutoxy/dim.lua", opts = {} },

  -- Color picker
  {
    "uga-rosa/ccc.nvim",
    lazy = false,
    opts = {
      bar_char = "█",
      point_char = "▍",
      highlighter = {
        auto_enable = true,
      },
    },
    config = function(_, opts)
      -- Must be set for this plugin to work. Will also be set by
      -- "mange.theme", but load order is not as strict. Also, if "mange.theme"
      -- fails for some reason, this plugin can still work with this config
      -- set.
      vim.o.termguicolors = true
      require("ccc").setup(opts)
    end,
  },

  -- A nicer-looking quicklist-like window
  {
    "folke/trouble.nvim",
    cmd = { "TroubleToggle", "Trouble" },
    opts = { use_diagnostic_signs = true },
  },

  -- Show lightbulbs when code actions are available on the current line
  {
    "kosayoda/nvim-lightbulb",
    opts = { autocmd = { enabled = true } },
  },

  -- Show semantic/scope location of cursor in current buffer
  {
    "SmiteshP/nvim-navic",
    opts = {
      highlight = true,
      separator = "  ",
      icons = icons.kinds,
    },
  },

  -- Indentation guides
  {
    "lukas-reineke/indent-blankline.nvim",
    opts = {
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
    },
  },

  {
    "hoob3rt/lualine.nvim",
    opts = function(_)
      local function fg(name)
        return function()
          ---@type {foreground?:number}?
          local hl = vim.api.nvim_get_hl_by_name(name, true)
          return hl
            and hl.foreground
            and { fg = string.format("#%06x", hl.foreground) }
        end
      end

      return {
        options = {
          theme = "catppuccin",
          icons_enabled = true,
          globalstatus = true,
          disabled_filetypes = { statusline = { "lazy" } },
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = {
            {
              function()
                return require("nvim-navic").get_location()
              end,
              cond = function()
                return package.loaded["nvim-navic"]
                  and require("nvim-navic").is_available()
              end,
            },
          },
          lualine_c = {},
          lualine_x = {},
          lualine_y = {
            "searchcount",
          },
          lualine_z = {
            {
              "progress",
              separator = "",
            },
            {
              "location",
            },
            {
              require("lazy.status").updates,
              cond = require("lazy.status").has_updates,
              color = fg "Special",
            },
          },
        },
        winbar = {
          lualine_a = {
            {
              "filetype",
              icon_only = true,
              padding = { left = 1, right = 1 },
            },
          },
          lualine_b = {
            {
              "filename",
              path = 0,
              symbols = { modified = "  ", readonly = "  ", unnamed = "" },
            },
          },
          lualine_c = {},
          lualine_x = {
            "diagnostics",
          },
          lualine_y = {
            {
              "diff",
              symbols = {
                added = icons.git.added,
                modified = icons.git.modified,
                removed = icons.git.removed,
              },
            },
          },
          lualine_z = {},
        },
        inactive_winbar = {
          lualine_a = {
            {
              "filetype",
              icon_only = true,
              padding = { left = 1, right = 1 },
            },
          },
          lualine_b = {
            {
              "filename",
              path = 0,
              symbols = { modified = "  ", readonly = "  ", unnamed = "" },
            },
          },
          lualine_c = {},
          lualine_x = {
            "diagnostics",
          },
          lualine_y = {
            {
              "diff",
              symbols = {
                added = icons.git.added,
                modified = icons.git.modified,
                removed = icons.git.removed,
              },
            },
          },
          lualine_z = {},
        },
        extensions = {
          "man",
          "nvim-dap-ui",
          "quickfix",
          "symbols-outline",
        },
      }
    end,
  },

  {
    "simrat39/symbols-outline.nvim",
    opts = {
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
        "String",
        "Number",
        "Boolean",
        "Array",
        "Object",
        "Key",
        "Null",
        "EnumMember",
        "Struct",
        "Event",
        "Operator",
        "TypeParameter",
      },
      winblend = 20,
    },
  },
}
