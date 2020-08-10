local awful = require("awful")
local which_keys = require("which_keys")
local actions = require("actions")

local function playerctl(command)
  return function()
    awful.spawn({"playerctl", command}, false)
  end
end

local media_mode = which_keys.new_chord(
  "media",
  {
    keybindings = {
      -- Playerctl
      which_keys.key("h", "previous", playerctl("previous"), {group = "Player", which_key_sticky = true}),
      which_keys.key("j", "play-pause", playerctl("play-pause"), {group = "Player"}),
      which_keys.key("k", "play-pause", playerctl("play-pause"), {group = "Player"}),
      which_keys.key("l", "next", playerctl("next"), {group = "Player", which_key_sticky = true}),

      -- Volume
      which_keys.key(
        {{"Shift"}, "+"},
        "vol +", actions.volume_change("+5"),
        {group = "Volume", which_key_key = "+", which_key_sticky = true}
      ),
      which_keys.key(
        "=",
        "vol +", actions.volume_change("+5"),
        {group = "Volume", which_key_sticky = true}
      ),
      which_keys.key(
        "-",
        "vol -", actions.volume_change("-5"),
        {group = "Volume", which_key_sticky = true}
      ),
      which_keys.key(
        "0",
        "toggle-mute", actions.volume_mute_toggle(),
        {group = "Volume", which_key_sticky = true}
      ),

      which_keys.key("g", "volume-gui", actions.volume_gui(), {group = "Volume"}),
      which_keys.key("t", "volume-tui", actions.volume_tui(), {group = "Volume"}),
    },
    stop_key = {"Escape", "Enter", "Space", "q"},
    -- Does not work as it will react to me releasing the triggering keybinds
    -- allowed_keys = {"h", "j", "k", "l"},
    start_callback = function() end,
    stop_callback = function() end
  }
)

return media_mode
