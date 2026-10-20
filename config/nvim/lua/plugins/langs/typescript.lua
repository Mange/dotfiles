return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        eslint = true,
        tailwindcss = true,
        biome = true,
        tsc = true,
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "biome", "prettier", stop_after_first = true },
        javascriptreact = { "biome", "prettier", stop_after_first = true },
        typescript = { "biome", "prettier", stop_after_first = true },
        typescriptreact = { "biome", "prettier", stop_after_first = true },
        vue = { "biome", "prettier", stop_after_first = true },
      },
    },
  },

  {
    "nvim-neotest/neotest",
    dependencies = {
      "marilari88/neotest-vitest",
    },
    opts = function(_, opts)
      vim.list_extend(opts.adapters, {
        require "neotest-vitest",
      })
    end,
  },
}
