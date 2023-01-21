return {
  -- Show keybinds while waiting for the next key. Allows more complicated
  -- keybinds to be remembered.
  {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup()
    end,
  },

  -- Nicer UIs
  {
    "stevearc/dressing.nvim",
    opts = {
      select = { backend = { "telescope", "builtin" } },
    },
  },

  -- Dim unused variables
  { "narutoxy/dim.lua", opts = {} },

  -- Show color previews
  -- Fork of norcalli/nvim-colorizer.lua
  -- See: https://github.com/norcalli/nvim-colorizer.lua/pull/55
  {
    "DarwinSenior/nvim-colorizer.lua",
    config = function()
      -- Must be set for this plugin to work. Will also be set by
      -- "mange.theme", but load order is not as strict. Also, if "mange.theme"
      -- fails for some reason, this plugin can still work with this config
      -- set.
      vim.o.termguicolors = true

      -- Enable for all files not covered by color-capable LSPs and render as
      -- virtualtext.
      require("colorizer").setup({ "*", "!tsx", "!css", "!html" }, {
        mode = "virtualtext",
      })
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
    dependencies = { "antoinemadec/FixCursorHold.nvim" },
    opts = { autocmd = { enabled = true } },
  },

  -- Show semantic/scope location of cursor in current buffer
  {
    "SmiteshP/nvim-navic",
    opts = {
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
    opts = {
      options = {
        icons_enabled = true,
        theme = "catppuccin",

        -- component_separators = { "", "" },
        -- section_separators = { "", "" },

        component_separators = "|",
        -- section_separators = { left = "", right = "" },

        disabled_filetypes = {},
      },
      sections = {
        lualine_a = {
          {
            "mode",
            separator = { right = "" },
            padding = { left = 1, right = 1 },
          },
        },
        lualine_b = {
          {
            "filetype",
            icon_only = true,
            separator = "",
            padding = { left = 1 },
          },
          { "filename", padding = 1, separator = "" },
        },
        lualine_c = {},
        lualine_x = {},
        lualine_y = {
          "diff",
          "diagnostics",
        },
        lualine_z = {
          {
            "progress",
            separator = { left = "" },
          },
          {
            "location",
            padding = { right = 1, left = 2 },
          },
        },
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = { "filename" },
        lualine_c = {},
        lualine_x = {},
        lualine_y = { "location" },
        lualine_z = {},
      },
      extensions = {
        "quickfix",
      },
    },
  },

  {
    -- Use fork with this PR implemented:
    --   https://github.com/simrat39/symbols-outline.nvim/pull/169
    -- "simrat39/symbols-outline.nvim",
    "mxsdev/symbols-outline.nvim",
    branch = "merge-jsx-tree",
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
    },
  },
}
