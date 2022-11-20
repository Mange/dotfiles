local actions = require "actions"

local M = {}

M.global = {
  ["mod+`"] = {},
  ["mod+1"] = {},
  ["mod+2"] = {},
  ["mod+3"] = {},
  ["mod+4"] = {},
  ["mod+5"] = {},
  ["mod+6"] = {},
  ["mod+7"] = {},
  ["mod+8"] = {},
  ["mod+9"] = {},
  ["mod+0"] = {},
  ["mod+-"] = {},
  ["mod+plus"] = {},
  ["mod+backspace"] = {},

  ["mod+tab"] = {},
  ["mod+q"] = {},
  -- ["mod+Q"] = {}, -- Used by clients
  ["mod+w"] = {},
  ["mod+e"] = {},
  ["mod+r"] = {},
  ["mod+t"] = {},
  ["mod+y"] = {},
  ["mod+u"] = {},
  ["mod+i"] = {},
  -- ["mod+o"] = {}, -- Used by clients
  ["mod+p"] = {
    actions.focus_by_index(-1),
    "Previous client",
    group = "Client",
  },
  ["mod+["] = {},
  ["mod+]"] = {},
  ["mod+\\"] = {},

  ["mod+a"] = {},
  ["mod+s"] = {},
  ["mod+d"] = { actions.rofi(), "Rofi", group = "Apps" },
  -- ["mod+f"] = {}, -- Used by clients
  -- ["mod+F"] = {}, -- Used by clients
  ["mod+g"] = {
    actions.dropdown_terminal(),
    "Terminal dropdown",
    groups = "Apps",
  },
  ["mod+G"] = {
    actions.dropdown_calculator(),
    "Calculator dropdown",
    groups = "Apps",
  },
  ["mod+h"] = { actions.focus "left", "Focus ←", group = "Client" },
  ["mod+j"] = { actions.focus "down", "Focus ↓", group = "Client" },
  ["mod+k"] = { actions.focus "up", "Focus ↑", group = "Client" },
  ["mod+l"] = { actions.focus "right", "Focus →", group = "Client" },
  ["mod+;"] = {},
  ["mod+'"] = {},
  ["mod+return"] = {
    actions.spawn { "samedirwezterm" },
    "Terminal (samedir)",
    group = "Apps",
  },
  ["mod+shift+return"] = {
    actions.spawn { "wezterm" },
    "Terminal (~)",
    group = "Apps",
  },

  ["mod+z"] = {},
  ["mod+x"] = {},
  ["mod+c"] = {},
  ["mod+v"] = {},
  ["mod+b"] = {},
  ["mod+n"] = { actions.focus_by_index(1), "Next client", group = "Client" },
  ["mod+m"] = {},
  ["mod+,"] = {},
  ["mod+."] = {},
  ["mod+/"] = {},

  ["mod+space"] = {},
  ["mod+left"] = {},
  ["mod+up"] = {},
  ["mod+down"] = {},
  ["mod+right"] = {},
}

M.clients = {
  ["mod+Q"] = { actions.client_close, "Kill client", group = "Client" },
  ["mod+f"] = {
    actions.client_toggle_fullscreen,
    "Fullscreen toggle",
    group = "Client",
  },
  ["mod+F"] = {
    actions.client_toggle_floating,
    "Floating toggle",
    group = "Client",
  },
  ["mod+o"] = {
    actions.client_move_other_screen,
    "To other screen",
    group = "Client",
  },
}

return M
