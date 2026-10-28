return {
  -- Show keybinds while waiting for the next key. Allows more complicated
  -- keybinds to be remembered.
  {
    "folke/which-key.nvim",
    opts = {
      filter = function(mapping)
        return mapping.desc ~= "diffview_ignore"
      end,
    },
  },
}
