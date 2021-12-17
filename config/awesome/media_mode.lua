local which_keys = require "module.which_keys"
local actions = require "actions"

local media_mode = which_keys.new_chord("media", {
  keybindings = {
    -- Playerctl
    which_keys.key(
      "h",
      "previous",
      actions.playerctl_previous(),
      { group = "Player", which_key_sticky = true }
    ),
    which_keys.key(
      "j",
      "play-pause",
      actions.playerctl_play_pause(),
      { group = "Player" }
    ),
    which_keys.key(
      "k",
      "play-pause",
      actions.playerctl_play_pause(),
      { group = "Player" }
    ),
    which_keys.key(
      "l",
      "next",
      actions.playerctl_next(),
      { group = "Player", which_key_sticky = true }
    ),

    -- Volume
    which_keys.key(
      "=",
      "vol +",
      actions.volume_change "+5",
      { group = "Volume", which_key_key = "+", which_key_sticky = true }
    ),
    which_keys.key(
      "-",
      "vol -",
      actions.volume_change "-5",
      { group = "Volume", which_key_sticky = true }
    ),
    which_keys.key(
      "0",
      "toggle-mute",
      actions.volume_mute_toggle(),
      { group = "Volume", which_key_sticky = true }
    ),

    which_keys.key(
      "g",
      "volume-gui",
      actions.volume_gui(),
      { group = "Volume" }
    ),
    which_keys.key(
      "t",
      "volume-tui",
      actions.volume_tui(),
      { group = "Volume" }
    ),
  },
  stop_key = { "Escape", "Enter", "Space", "q" },
  -- Does not work as it will react to me releasing the triggering keybinds
  -- allowed_keys = {"h", "j", "k", "l"},
  start_callback = function() end,
  stop_callback = function() end,
})

return media_mode
