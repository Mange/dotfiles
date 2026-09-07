return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        ["markdown.mdx"] = { "biome", "prettier", stop_after_first = true },
        markdown = { "biome", "prettier", stop_after_first = true },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        marksman = true,
      },
    },
  },
}
