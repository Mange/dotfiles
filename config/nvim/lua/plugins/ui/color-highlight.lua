return {
  {
    "brenoprata10/nvim-highlight-colors",
    opts = {
      render = "virtual",
      virtual_symbol_position = "inline",
    },
    config = function(_, opts)
      vim.opt.termguicolors = true
      require("nvim-highlight-colors").setup(opts)
    end,
  },
}
