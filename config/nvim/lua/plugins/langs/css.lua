return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        css = { "biome", "prettier", stop_after_first = true },
        scss = { "biome", "prettier", stop_after_first = true },
        less = { "biome", "prettier", stop_after_first = true },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        cssls = true,
      },
    },
  },
}
