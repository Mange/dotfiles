return {
  -- A better version of vim.diagnostic's `virtual_lines`.
  -- Sure, `virtual_lines` look cooler in a sense, but the virtual lines causes
  -- the whole document to jump around and they are extremely noisy when a file
  -- contains a lot of diagnostics.
  --
  -- This plugin uses floating windows instead, so it becomes a lot less
  -- jarring when scrolling around in a file.
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    priority = 1000, -- Needs to be loaded in first
    opts = {
      preset = "powerline",
      options = {
        show_source = { enabled = true, if_many = true },
        use_icons_from_diagnostic = true,
        set_arrow_to_diag_color = true,
        throttle = 100, -- ms
        overflow = { mode = "oneline" },
        severity = {
          vim.diagnostic.severity.ERROR,
          vim.diagnostic.severity.WARN,
        },
      },
    },
  },
}
