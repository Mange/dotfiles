local catppuccin = require "catppuccin"

local theme = {}

local function theme_overrides()
  -- Highlight line number instead of showing a sign on lines with diagnostics
  vim.cmd [[
    highlight DiagnosticLineNrError guibg=#51202A guifg=#FF0000 gui=bold
    highlight DiagnosticLineNrWarn guibg=#51412A guifg=#FFA500 gui=bold
    highlight DiagnosticLineNrInfo guibg=#1E535D guifg=#00FFFF gui=bold
    highlight DiagnosticLineNrHint guibg=#1E205D guifg=#0000FF gui=bold

    sign define DiagnosticSignError text= texthl=DiagnosticSignError linehl= numhl=DiagnosticLineNrError
    sign define DiagnosticSignWarn text= texthl=DiagnosticSignWarn linehl= numhl=DiagnosticLineNrWarn
    sign define DiagnosticSignInfo text= texthl=DiagnosticSignInfo linehl= numhl=DiagnosticLineNrInfo
    sign define DiagnosticSignHint text= texthl=DiagnosticSignHint linehl= numhl=DiagnosticLineNrHint
  ]]

  -- Use background colors to highlight in vimdiff
  vim.cmd [[
    highlight DiffAdd guifg=NONE guibg=#384047
    highlight DiffChange guifg=NONE guibg=#463f47

    " Changed text inside of a line (DiffChange)
    highlight DiffText guifg=#FAE3B0 guibg=NONE gui=bold

    " DiffDelete uses a conceal character that spans the entire line. Highlight
    " that character instead of the background behind it.
    highlight DiffDelete guifg=#F28FAD guibg=NONE
  ]]
end

function theme.reload()
  require("plenary.reload").reload_module "mange.theme"
  require("mange.theme").setup()
end
function theme.setup()
  vim.o.termguicolors = true

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

  catppuccin.setup {
    transparent_background = true,
    term_colors = true,
    styles = {
      comments = "NONE",
      functions = "NONE",
      keywords = "bold,italic",
      strings = "NONE",
      variables = "NONE",
    },
    integrations = {
      treesitter = true,
      native_lsp = {
        enabled = true,
        virtual_text = {
          errors = "NONE",
          hints = "NONE",
          warnings = "NONE",
          information = "NONE",
        },
        underlines = {
          errors = "underline",
          hints = "underline",
          warnings = "underline",
          information = "underline",
        },
      },
      lsp_trouble = false,
      lsp_saga = false,
      gitgutter = false,
      gitsigns = true,
      telescope = true,
      nvimtree = {
        enabled = false,
        show_root = false,
      },
      which_key = true,
      indent_blankline = {
        enabled = true,
        colored_indent_levels = true,
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
    },
  }

  vim.cmd [[silent! colorscheme catppuccin]]

  theme_overrides()
end

return theme
