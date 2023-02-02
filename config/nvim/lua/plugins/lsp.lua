return {
  { "jose-elias-alvarez/null-ls.nvim" },
  { "lukas-reineke/lsp-format.nvim" },
  {
    "lvimuser/lsp-inlayhints.nvim",
    opts = {
      inlay_hints = {
        type_hints = {
          prefix = "  ",
          remove_colon_start = true,
        },
        parameter_hints = {
          prefix = "",
        },
      },
      labels_separator = "",
    },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "mange.lsp"
    end,
  },
}
