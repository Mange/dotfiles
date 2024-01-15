return {
  -- Color picker
  {
    "uga-rosa/ccc.nvim",
    lazy = false,
    opts = {
      bar_char = "█",
      point_char = "▍",
      highlighter = {
        auto_enable = true,
      },
    },
    config = function(_, opts)
      -- Must be set for this plugin to work. Will also be set by
      -- "mange.theme", but load order is not as strict. Also, if "mange.theme"
      -- fails for some reason, this plugin can still work with this config
      -- set.
      vim.o.termguicolors = true
      require("ccc").setup(opts)
    end,
  },
}
