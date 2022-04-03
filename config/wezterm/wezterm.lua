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

  -- Super annoying when looking at binary output
  warn_about_missing_glyphs = false,

  disable_default_key_bindings = true,
  keys = {
    { mods = "CTRL|SHIFT", key = "z", action = "QuickSelect" },
    {
      mods = "CTRL|SHIFT",
      key = "x",
      action = "ActivateCopyMode",
    },
    {
      mods = "CTRL|SHIFT",
      key = "e",
      action = wezterm.action {
        QuickSelectArgs = {
          label = "open url",
          patterns = {
            "https?://\\S+",
          },
          action = wezterm.action_callback(function(window, pane)
            local url = window:get_selection_text_for_pane(pane)
            wezterm.open_with(url)
          end),
        },
      },
    },
    {
      mods = "CTRL|SHIFT",
      key = "c",
      action = wezterm.action { CopyTo = "ClipboardAndPrimarySelection" },
    },
    {
      mods = "CTRL|SHIFT",
      key = "v",
      action = wezterm.action { PasteFrom = "Clipboard" },
    },
    {
      mods = "CTRL|SHIFT",
      key = "s",
      action = wezterm.action { PasteFrom = "PrimarySelection" },
    },
    {
      mods = "CTRL|SHIFT",
      key = "f",
      action = wezterm.action { Search = { CaseInSensitiveString = "" } },
    },
    {
      mods = "CTRL|SHIFT",
      key = "r",
      action = wezterm.action { Search = { Regex = "" } },
    },
    {
      mods = "CTRL|SHIFT",
      key = "-",
      action = "DecreaseFontSize",
    },
    {
      mods = "CTRL|SHIFT",
      key = "=",
      action = "IncreaseFontSize",
    },
    {
      mods = "CTRL|SHIFT",
      key = "0",
      action = "ResetFontSize",
    },
    {
      mods = "CTRL|SHIFT",
      key = "PageUp",
      action = wezterm.action { ScrollByPage = -1 },
    },
    {
      mods = "CTRL|SHIFT",
      key = "PageDown",
      action = wezterm.action { ScrollByPage = 1 },
    },
    {
      mods = "CTRL|SHIFT",
      key = "UpArrow",
      action = wezterm.action { ScrollToPrompt = -1 },
    },
    {
      mods = "CTRL|SHIFT",
      key = "DownArrow",
      action = wezterm.action { ScrollToPrompt = 1 },
    },
  },
}
