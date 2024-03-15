return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
    config = function()
      local colors = require("catppuccin.palettes").get_palette()
      local U = require "catppuccin.utils.colors"

      local opts = {
        flavour = "mocha",
        transparent_background = true,
        term_colors = true,
        integrations = {
          treesitter = true,
          native_lsp = {
            enabled = true,
            virtual_text = {
              errors = {},
              hints = {},
              warnings = {},
              information = {},
            },
            underlines = {
              errors = { "underline" },
              hints = {},
              warnings = { "undercurl" },
              information = {},
            },
          },
          lsp_trouble = true,
          cmp = true,
          gitsigns = true,
          leap = true,
          telescope = true,
          navic = {
            enabled = true,
            custom_bg = "NONE",
          },
          dap = {
            enabled = false,
            enable_ui = false,
          },
          which_key = true,
          indent_blankline = {
            enabled = true,
            colored_indent_levels = false,
          },
          neogit = true,
          markdown = true,
          notify = true,
          symbols_outline = true,
        },
        color_overrides = {},
        custom_highlights = {
          -- Disabled by transparent_background for some reason.
          CursorLine = { bg = U.darken(colors.surface0, 0.64, colors.base) },

          DiffAdd = { bg = "#384047" },
          DiffChange = { bg = "#463f47" },

          -- Changed text inside of a line (DiffChange)
          DiffText = { fg = "#FAE3B0", style = { "bold" } },

          -- DiffDelete uses a conceal character that spans the entire line. Highlight
          -- that character instead of the background behind it.
          DiffDelete = { fg = "#F28FAD" },

          Folded = { bg = colors.surface0 },
          FoldedInfo = { fg = colors.subtext0 },

          -- Not set by the notify integration?
          -- Causes a warning if not set, so let's set it ourselves.
          NotifyBackground = { bg = colors.surface0 },

          LspReferenceRead = { bg = "#5f5840" },
          LspReferenceText = { bg = "#504945" },
          LspReferenceWrite = { bg = "#6c473e" },
        },
      }

      require("catppuccin").setup(opts)
      vim.cmd.colorscheme "catppuccin"
    end,
  },
}
