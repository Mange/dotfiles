local awful = require("awful")
local which_keys = require("which_keys")

local function playerctl(command)
  return function()
    awful.spawn({"playerctl", command}, false)
  end
end

local function pactl(command, sink, param)
  return function()
    awful.spawn({"pactl", command, sink, param}, false)
  end
end

local function pactl_default(command, param)
  return function()
    awful.spawn({"pactl", command, "@DEFAULT_SINK@", param}, false)
  end
end

local media_mode = which_keys.new_mode(
  "Media mode",
  {
    keybindings = {
      -- Playerctl
      which_keys.key("h", "previous", playerctl("previous"), {group = "Player"}),
      which_keys.key("j", "play-pause", playerctl("play-pause"), {group = "Player"}),
      which_keys.key("k", "play-pause", playerctl("play-pause"), {group = "Player"}),
      which_keys.key("l", "next", playerctl("next"), {group = "Player"}),

      -- Volume
      which_keys.key(
        {{"Shift"}, "+"},
        "vol +", pactl_default("set-sink-volume", "+5%"),
        {group = "Volume", which_key_key = "+"}
      ),
      which_keys.key(
        "=",
        "vol +", pactl_default("set-sink-volume", "+5%"),
        {group = "Volume"}
      ),
      which_keys.key(
        "-",
        "vol -", pactl_default("set-sink-volume", "-5%"),
        {group = "Volume"}
      ),
      which_keys.key(
        "0",
        "toggle-mute", pactl_default("set-sink-mute", "toggle"),
        {group = "Volume"}
      ),
    },
    stop_key = {"Escape", "Enter", "Space", "q"},
    timeout = 5, -- seconds
    -- Does not work as it will react to me releasing the triggering keybinds
    -- allowed_keys = {"h", "j", "k", "l"},
    start_callback = function() end,
    stop_callback = function() end
  }
)

return media_mode
