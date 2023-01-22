return {
  {
    "catppuccin/nvim",
    priority = 1000,
    lazy = false,
    init = function()
      vim.g.catppuccin_flavour = "mocha"
    end,
  },
}
