return {
  -- Show keybinds while waiting for the next key. Allows more complicated
  -- keybinds to be remembered.
  {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup()
    end,
  },
}
