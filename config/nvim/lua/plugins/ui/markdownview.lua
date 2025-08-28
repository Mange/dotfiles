return {
  {
    "OXY2DEV/markview.nvim",
    lazy = false,

    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },

    -- So nvim-treesitter is loaded first
    priority = 49,

    opts = {
      checkboxes = { enable = false },
    },
  },
}
