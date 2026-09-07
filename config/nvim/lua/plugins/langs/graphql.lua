return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        graphql = { "biome", "prettier", stop_after_first = true },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        graphql = true,
      },
    },
  },
}
