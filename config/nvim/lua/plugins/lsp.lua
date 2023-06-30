return {
  { "jose-elias-alvarez/null-ls.nvim" },
  { "lukas-reineke/lsp-format.nvim" },
  {
    "lvimuser/lsp-inlayhints.nvim",
    event = "LspAttach",
    branch = "anticonceal",
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "mange.lsp"
    end,
  },
}
