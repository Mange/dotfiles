return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        nil_ls = true,
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        nix = { "statix" },
      },
    },
  },
}
