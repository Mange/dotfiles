local wezterm = require "wezterm"

local function font(name, params)
  return wezterm.font_with_fallback(
    { name, "Symbols Nerd Font", "Noto Color Emoji" },
    params
  )
end

local color_scheme = "Catppuccin Mocha"
local env_scheme = "dark"

-- local appearance = wezterm.gui.get_appearance()
-- if appearance:find "Light" then
--   color_scheme = "Catppuccin Latte"
--   env_scheme = "light"
-- end

return {
  term = "wezterm", -- Requires terminfo to be installed
  check_for_updates = false,
  color_scheme = color_scheme,
  set_environment_variables = {
    THEME = env_scheme,
  },
  font = font "Jetbrains Mono",
  hide_tab_bar_if_only_one_tab = true,
  window_background_opacity = 0.8,

  -- Disabled until Wayland support can be remade to work in Hyprland.
  -- https://github.com/wez/wezterm/issues/4483
  enable_wayland = false,
  audible_bell = "Disabled", -- Disabled on Wayland, not on X11

  -- Don't accidentally select stuff when I click on a window and accidentally move a few pixels
  swallow_mouse_click_on_window_focus = true,

  -- Makes font resizing work better in tiling window managers.
  adjust_window_size_when_changing_font_size = false,

  -- Super annoying when looking at binary output
  warn_about_missing_glyphs = false,

  -- Don't do animations. Distracting and makes things feel slower.
  animation_fps = 1,
  cursor_blink_ease_in = "Constant",
  cursor_blink_ease_out = "Constant",

  -- Kitty encoding breaks some of my vim bindings. I should
  -- perhaps debug that at some later time.
  -- Example keybind that breaks: Anything involving $ and ?.
  -- Example: cmap $$, Neogit's $ and ? mapping in Status.
  -- enable_kitty_keyboard = true,
  enable_csi_u_key_encoding = true,

  disable_default_key_bindings = true,
  keys = {
    {
      mods = "CTRL|SHIFT",
      key = "u",
      action = wezterm.action.CharSelect {
        copy_on_select = true,
        copy_to = "ClipboardAndPrimarySelection",
      },
    },
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
      key = "phys:Minus", -- Ctrl+Shift+[-]
      action = "DecreaseFontSize",
    },
    {
      mods = "CTRL|SHIFT",
      key = "phys:Equal", -- Ctrl+Shift+[+]
      action = "IncreaseFontSize",
    },
    {
      mods = "CTRL|SHIFT",
      key = "phys:0", -- Ctrl+Shift+0
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
    -- Shift Escape -> ~
    -- This is mainly for using 60% keyboards where I cannot reprogram escape to
    -- default to [`~] and having Escape on the Fn layer.
    -- Without this the behavior is to delete the entire line, which is awful with
    -- my muscle memory of Shift+<Key before 1>.
    {
      mods = "SHIFT",
      key = "Escape",
      action = wezterm.action { SendString = "~" },
    },
  },
}
