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

        -- Terminal handles transparent background differently from Neovide.
        -- Neovide should not use transparent background in the theme.
        transparent_background = not vim.g.neovide,

        term_colors = true,
        integrations = {
          cmp = true,
          dap = { enabled = false, enable_ui = false },
          gitsigns = true,
          indent_blankline = { enabled = true, colored_indent_levels = false },
          leap = true,
          lsp_trouble = true,
          markdown = true,
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
          navic = { enabled = true, custom_bg = "NONE" },
          neogit = true,
          neotest = true,
          notify = true,
          symbols_outline = true,
          telescope = true,
          treesitter = true,
          ufo = true,
          which_key = true,
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

          LightBulbVirtualText = { fg = colors.yellow },
        },
      }

      require("catppuccin").setup(opts)
      vim.cmd.colorscheme "catppuccin"

      -- Neovim theme stuff
      vim.o.guifont = "Jetbrains Mono"
      vim.g.neovide_transparency = 0.8
      vim.g.neovide_theme = "dark"
      vim.g.neovide_background_color = colors.base
      vim.g.neovide_floating_blur_amount_x = 2.0
      vim.g.neovide_floating_blur_amount_y = 2.0
    end,
  },
}
