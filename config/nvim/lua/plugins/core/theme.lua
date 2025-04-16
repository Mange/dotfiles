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

        -- Does not work like I want it to. It removes *all* backgrounds, not
        -- just the Normal background. See overrides below.
        -- transparent_background = not vim.g.neovide,
        dim_inactive = { enabled = false },

        term_colors = true,
        integrations = {
          cmp = true,
          dap = { enabled = false, enable_ui = false },
          diffview = true,
          fidget = true,
          flash = true,
          gitsigns = true,
          indent_blankline = { enabled = true, colored_indent_levels = false },
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
          neogit = true,
          neotest = true,
          nvim_surround = true,
          semantic_tokens = true,
          telescope = true,
          treesitter = true,
          treesitter_context = true,
          ufo = true,
          which_key = true,
        },
        custom_highlights = {
          -- Setup transparent background for normal backgrounds. Using
          -- catppuccin's `transparent_background` setting removes all
          -- backgrounds from all plugins, which is not what I want.
          --
          -- Neovide does not have a "default background" color to fall back
          -- to, so use normal theme.
          Normal = vim.g.neovide and {} or { bg = "NONE" },
          NormalNC = vim.g.neovide and {} or { bg = "NONE" },
          TelescopeNormal = vim.g.neovide and {} or { bg = colors.base },

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

          LspReferenceRead = { bg = "#5f5840" },
          LspReferenceText = { bg = "#504945" },
          LspReferenceWrite = { bg = "#6c473e" },

          LightBulbVirtualText = { fg = colors.yellow },
        },
      }

      require("catppuccin").setup(opts)
      vim.cmd.colorscheme "catppuccin"

      -- Neovim theme stuff
      vim.g.neovide_transparency = 0.9 -- Until Niri gets blurred backgrounds
      vim.g.neovide_theme = "dark"
      vim.g.neovide_background_color = colors.base
      vim.g.neovide_floating_blur_amount_x = 2.0
      vim.g.neovide_floating_blur_amount_y = 2.0
    end,
  },
}
