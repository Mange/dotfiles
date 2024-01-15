local icons = require "config.icons"

return {
  {
    "hoob3rt/lualine.nvim",
    opts = function(_)
      local function fg(name)
        return function()
          ---@type {foreground?:number}?
          local hl = vim.api.nvim_get_hl_by_name(name, true)
          return hl
            and hl.foreground
            and { fg = string.format("#%06x", hl.foreground) }
        end
      end

      return {
        options = {
          theme = "catppuccin",
          icons_enabled = true,
          globalstatus = true,
          disabled_filetypes = { statusline = { "lazy" } },
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {
            "searchcount",
          },
          lualine_z = {
            {
              "progress",
              separator = "",
            },
            {
              "location",
            },
            {
              require("lazy.status").updates,
              cond = require("lazy.status").has_updates,
              color = fg "Special",
            },
          },
        },
        winbar = {
          lualine_a = {
            {
              "filetype",
              icon_only = true,
              padding = { left = 1, right = 1 },
            },
          },
          lualine_b = {
            {
              "filename",
              path = 0,
              symbols = { modified = "  ", readonly = "  ", unnamed = "" },
            },
          },
          lualine_c = {},
          lualine_x = {
            "diagnostics",
          },
          lualine_y = {
            {
              "diff",
              symbols = {
                added = icons.git.added,
                modified = icons.git.modified,
                removed = icons.git.removed,
              },
            },
          },
          lualine_z = {},
        },
        inactive_winbar = {
          lualine_a = {
            {
              "filetype",
              icon_only = true,
              padding = { left = 1, right = 1 },
            },
          },
          lualine_b = {
            {
              "filename",
              path = 0,
              symbols = { modified = "  ", readonly = "  ", unnamed = "" },
            },
          },
          lualine_c = {},
          lualine_x = {
            "diagnostics",
          },
          lualine_y = {
            {
              "diff",
              symbols = {
                added = icons.git.added,
                modified = icons.git.modified,
                removed = icons.git.removed,
              },
            },
          },
          lualine_z = {},
        },
        extensions = {
          "man",
          "nvim-dap-ui",
          "quickfix",
          "symbols-outline",
        },
      }
    end,
  },
}
