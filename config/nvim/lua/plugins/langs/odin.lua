return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ols = true,
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        odin = { "odinfmt" },
      },
    },
  },
}
