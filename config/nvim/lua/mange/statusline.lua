require("lualine").setup {
  options = {
    icons_enabled = true,
    theme = "catppuccin",

    -- component_separators = { "", "" },
    -- section_separators = { "", "" },

    component_separators = "|",
    -- section_separators = { left = "", right = "" },

    disabled_filetypes = {},
  },
  sections = {
    lualine_a = {
      {
        "mode",
        separator = { right = "" },
        padding = { left = 1, right = 1 },
      },
    },
    lualine_b = {
      {
        "filetype",
        icon_only = true,
        separator = "",
        padding = { left = 1 },
      },
      { "filename", padding = 1, separator = "" },
    },
    lualine_c = {},
    lualine_x = {},
    lualine_y = {
      "diff",
      "diagnostics",
    },
    lualine_z = {
      {
        "progress",
        separator = { left = "" },
      },
      {
        "location",
        padding = { right = 1, left = 2 },
      },
    },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = { "filename" },
    lualine_c = {},
    lualine_x = {},
    lualine_y = { "location" },
    lualine_z = {},
  },
  extensions = {
    "quickfix",
  },
}
