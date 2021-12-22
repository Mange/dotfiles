local wezterm = require "wezterm"

local function font(name, params)
  return wezterm.font_with_fallback(
    { name, "Symbols Nerd Font", "Noto Color Emoji" },
    params
  )
end

return {
  check_for_updates = false,
  color_scheme = "Catppuccino",
  color_schemes = {
    -- https://github.com/catppuccin/catppuccin/issues/17
    Catppuccino = {
      background = "#1E1E29",
      foreground = "#D7DAE0",
      selection_bg = "#2D293B",
      selection_fg = "#F0AFE1",
      cursor_bg = "#B3E1A3",
      cursor_fg = "#EADDA0",
      cursor_border = "#B3E1A3",

      scrollbar_thumb = "#B3E1A3",

      split = "#B3E1A3",

      ansi = {
        "#6E6C7C",
        "#E28C8C",
        "#B3E1A3",
        "#EADDA0",
        "#A4B9EF",
        "#C6AAE8",
        "#F0AFE1",
        "#D7DAE0",
      },
      brights = {
        "#6E6C7C",
        "#E28C8C",
        "#B3E1A3",
        "#EADDA0",
        "#A4B9EF",
        "#C6AAE8",
        "#F0AFE1",
        "#D7DAE0",
      },

      tab_bar = {
        background = "#15121C",
        active_tab = {
          bg_color = "#1E1E28",
          fg_color = "#D7DAE0",
        },
        inactive_tab = {
          bg_color = "#1B1923",
          fg_color = "#A4B9EF",
        },
        inactive_tab_hover = {
          bg_color = "#1E1E28",
          fg_color = "#D7DAE0",
        },
        new_tab = {
          bg_color = "#15121C",
          fg_color = "#6E6C7C",
        },
        new_tab_hover = {
          bg_color = "#1E1E28",
          fg_color = "#D7DAE0",
          italic = true,
        },
      },
    },
  },
  font = font "Fira Code",
  font_rules = {
    {
      italic = true,
      font = font("Victor Mono", { italic = true }),
    },
    {
      italic = true,
      intensity = "Bold",
      font = font("Victor Mono", { italic = true, weight = "DemiBold" }),
    },
    {
      intensity = "Bold",
      font = font("Fira Code", { weight = "DemiBold" }),
    },
    {
      intensity = "Half",
      font = font("Fira Code", { weight = "Light" }),
    },
  },
  hide_tab_bar_if_only_one_tab = true,
  window_background_opacity = 0.8,
}
