local gears = require "gears"
local actions = require "actions"
local which_keys = require "module.which_keys"

local M = {}

M.leader = which_keys.create {
  name = "leader",
  keys = {
    ["t"] = {
      function()
        print "Test!"
      end,
      "test",
      sticky = true,
    },
    ["e"] = { actions.emoji_selector(), "emojis" },
    ["c"] = {
      name = "client",
      keys = {
        ["s"] = {
          actions.on_focused_client(actions.client_toggle_sticky),
          "sticky-toggle",
        },
      },
    },
  },
}

local function start_leader_chord()
  return function()
    M.leader:start()
  end
end

-- Generate keybindings for 0-9 keys
M.global = {}
for i = 0, 10 do
  local num = i % 10 -- 10th key is "0" on the keyboard

  M.global["mod+" .. num] =
    { actions.goto_tag(i), "Go to tag " .. num, group = "Tag" }
  M.global["mod+shift+" .. num] =
    { actions.move_to_tag(i), "Move to tag " .. num, group = "Tag" }
  M.global["mod+ctrl+" .. num] =
    { actions.toggle_tag(i), "Toggle tag " .. num, group = "Tag" }
  M.global["mod+shift+ctrl+" .. num] =
    { actions.toggle_client_tag(i), "Toggle client tag " .. num, group = "Tag" }
end

M.global = gears.table.join(M.global, {
  ["mod+`"] = {
    actions.focus_urgent_client(),
    "Focus urgent",
    group = "Client",
  },
  -- ["mod+1"] = {}, -- See loop above
  -- ["mod+2"] = {},
  -- ["mod+3"] = {},
  -- ["mod+4"] = {},
  -- ["mod+5"] = {},
  -- ["mod+6"] = {},
  -- ["mod+7"] = {},
  -- ["mod+8"] = {},
  -- ["mod+9"] = {},
  -- ["mod+0"] = {},
  ["mod+-"] = {},
  ["mod+plus"] = {},
  ["mod+backspace"] = {},

  ["mod+tab"] = {},
  ["mod+q"] = {},
  -- ["mod+Q"] = {}, -- Used by clients
  ["mod+w"] = { actions.select_window(), "Windows", group = "Apps" },
  ["mod+e"] = { actions.emoji_selector(), "Emojis", group = "Apps" },
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

  ["mod+space"] = { start_leader_chord(), "Chord", group = "Awesome" },
  ["mod+left"] = {},
  ["mod+up"] = {},
  ["mod+down"] = {},
  ["mod+right"] = {},
})

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
