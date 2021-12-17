local wezterm = require "wezterm"

return {
  color_scheme = "Gruvbox Dark",
  font = wezterm.font_with_fallback {
    "Fira Code",
    "Symbols Nerd Font",
    "Noto Color Emoji",
  },
  hide_tab_bar_if_only_one_tab = true,
  window_background_opacity = 0.8,
}
