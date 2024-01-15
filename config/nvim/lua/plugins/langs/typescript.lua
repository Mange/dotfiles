return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "typescript",
        "javascript",
        "tsx",
      })
    end,
  },
  -- Insert closing </tags> automatically in HTML-like filetypes.
  -- (Also handles renames of opening tag)
  {
    "windwp/nvim-ts-autotag",
    opts = {},
    lazy = false,
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        eslint = {},
        tailwindcss = {},
      },
    },
  },
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = function()
      local api = require "typescript-tools.api"
      return {
        handlers = {
          -- Ignore 'This may be converted to an async function' diagnostics.
          ["textDocument/publishDiagnostics"] = api.filter_diagnostics { 80006 },
        },
        settings = {
          publish_diagnostic_on = "insert_leave",
          expose_as_code_action = {
            "fix_all",
            "add_missing_imports",
            "remove_unused",
            "remove_unused_imports",
            "organize_imports",
          },
          tsserver_file_preferences = {
            includeInlayParameterNameHints = "literals",
            includeCompletionsForModuleExports = true,
            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = true,
            includeInlayVariableTypeHintsWhenTypeMatchesName = false,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayEnumMemberValueHints = false,
            quotePreference = "auto",
          },
        },
      }
    end,
  },

  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        css = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        vue = { "prettier" },
      },
    },
  },
}
