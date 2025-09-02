return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        eslint = true,
        tailwindcss = true,
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
        on_attach = function(client)
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end,
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

  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
    },
    opts = function(_, opts)
      vim.list_extend(opts.adapters, {
        require "neotest-jest",
        require "neotest-vitest",
      })
    end,
  },
}
