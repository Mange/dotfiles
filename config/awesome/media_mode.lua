local awful = require("awful")
local naughty = require("naughty") -- Notification library

local function playerctl(command)
  return function()
    awful.spawn({"playerctl", command})
  end
end

local function pactl(command, sink, param)
  return function()
    awful.spawn({"pactl", command, sink, param})
  end
end

local media_mode = awful.keygrabber {
  keybindings = {
    -- Playerctl
    {{}, "h", playerctl("previous"), {description = "Previous", group = "Media"}},
    {{}, "j", playerctl("play-pause"), {description = "Play/pase", group = "Media"}},
    {{}, "k", playerctl("play-pause"), {description = "Play/pase", group = "Media"}},
    {{}, "l", playerctl("next"), {description = "Next", group = "Media"}},

    -- Volume
    {
      {"Shift"}, "=",
      pactl("set-sink-volume", "@DEFAULT_SINK@", "+5%"),
      {description = "Volume +", group = "Media"}
    },
    {
      {}, "=",
      pactl("set-sink-volume", "@DEFAULT_SINK@", "+5%"),
      {description = "Volume +", group = "Media"}
    },
    {
      {}, "-",
      pactl("set-sink-volume", "@DEFAULT_SINK@", "-5%"),
      {description = "Volume -", group = "Media"}
    },
    {
      {}, "0",
      pactl("set-sink-mute", "@DEFAULT_SINK@", "toggle"),
      {description = "Mute toggle", group = "Media"}
    }
  },
  stop_key = {'Escape', 'Enter', 'Space'},
  timeout = 5, -- seconds
  -- Does not work as it will react to me releasing the triggering keybinds
  -- allowed_keys = {'h', 'j', 'k', 'l'},
  start_callback = function() end,
  stop_callback = function() end
}

return media_mode
