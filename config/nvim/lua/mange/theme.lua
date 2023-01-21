local catppuccin = require "catppuccin"

local theme = {}

function theme.reload()
  require("plenary.reload").reload_module "mange.theme"
  require("mange.theme").setup()
end
function theme.setup()
  vim.o.termguicolors = true
  vim.g.catppuccin_flavour = "mocha"

  local colors = require("catppuccin.palettes").get_palette()
  local U = require "catppuccin.utils.colors"

  vim.diagnostic.config {
    -- virtual_text = {
    --   prefix = '●', -- Could be '■', '▎', 'x'
    --   source = "always",
    -- },
    virtual_text = false,
    signs = true,
    underline = true,
    float = {
      source = "always",
      border = "rounded",
    },
    severity_sort = true,
    update_in_insert = false,
  }
  local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end

  catppuccin.setup {
    dim_inactive = {
      enabled = false,
      shade = "dark",
      percentage = 0.15,
    },
    transparent_background = true,
    term_colors = true,
    compile = {
      enabled = false,
      path = vim.fn.stdpath "cache" .. "/catppuccin",
    },
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

      WinBarSeparator = { fg = colors.lavender },
    },
  }

  vim.cmd [[colorscheme catppuccin]]
end

return theme
