return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        graphql = { "prettier" },
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
