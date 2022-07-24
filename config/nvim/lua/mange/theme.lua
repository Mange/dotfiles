local catppuccin = require "catppuccin"

local theme = {}

function theme.reload()
  require("plenary.reload").reload_module "mange.theme"
  require("mange.theme").setup()
end
function theme.setup()
  vim.o.termguicolors = true

  local colors = require("catppuccin.palettes").get_palette()

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
    },
    severity_sort = true,
    update_in_insert = false,
  }
  local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end

  vim.g.catppuccin_flavour = "mocha"
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
    styles = {
      comments = {},
      conditionals = {},
      loops = {},
      functions = {},
      keywords = { "bold", "italic" },
      strings = {},
      variables = {},
      numbers = {},
      booleans = {},
      properties = {},
      types = {},
      operators = {},
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
          warnings = { "underline" },
          information = {},
        },
      },
      coc_nvim = false,
      lsp_trouble = true,
      cmp = true,
      lsp_saga = false,
      gitgutter = false,
      gitsigns = true,
      leap = false,
      telescope = true,
      nvimtree = {
        enabled = false,
        show_root = true,
        transparent_panel = false,
      },
      neotree = {
        enabled = false,
        show_root = true,
        transparent_panel = false,
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
      dashboard = true,
      neogit = true,
      vim_sneak = false,
      fern = false,
      barbar = false,
      bufferline = false,
      markdown = true,
      lightspeed = false,
      ts_rainbow = false,
      hop = false,
      notify = true,
      telekasten = false,
      symbols_outline = true,
      mini = false,
      aerial = false,
      vimwiki = false,
      beacon = false,
    },
    color_overrides = {},
    custom_highlights = {
      DiffAdd = { bg = "#384047" },
      DiffChange = { bg = "#463f47" },

      -- Changed text inside of a line (DiffChange)
      DiffText = { fg = "#FAE3B0", style = { "bold" } },

      -- DiffDelete uses a conceal character that spans the entire line. Highlight
      -- that character instead of the background behind it.
      DiffDelete = { fg = "#F28FAD" },
    },
  }

  vim.cmd [[colorscheme catppuccin]]
end

return theme
