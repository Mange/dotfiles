local wezterm = require "wezterm"

local function font(name, params)
  return wezterm.font_with_fallback(
    { name, "Symbols Nerd Font", "Noto Color Emoji" },
    params
  )
end

return {
  check_for_updates = false,
  color_scheme = "Catppuccin",
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
