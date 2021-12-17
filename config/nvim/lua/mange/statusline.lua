local gb = require "mange.gruvbox"

require("lualine").setup {
  options = {
    icons_enabled = true,
    theme = vim.tbl_deep_extend("force", require "lualine.themes.gruvbox", {
      normal = {
        a = { bg = gb.light4 },
        b = { bg = gb.dark1 },
        c = { bg = gb.dark1 },
      },
      insert = {
        b = { bg = gb.dark1 },
        c = { bg = gb.dark1 },
      },
      visual = {
        b = { bg = gb.dark1 },
        c = { bg = gb.dark1 },
      },
      replace = {
        b = { bg = gb.dark1 },
        c = { bg = gb.dark1 },
      },
      command = {
        b = { bg = gb.dark1 },
        c = { bg = gb.dark1 },
      },
      inactive = {
        b = { bg = gb.dark1 },
        c = { bg = gb.dark1 },
      },
    }),

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
