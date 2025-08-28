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
      preview = {
        icon_provider = "devicons",
        hybrid_modes = { "i" },
      },
      markdown = {
        list_items = {
          marker_minus = { add_padding = false },
          marker_dot = { add_padding = false },
        },
      },
    },
  },
}
