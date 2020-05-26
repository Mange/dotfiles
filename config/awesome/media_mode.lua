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

local media_mode = which_keys.new(
  "Media mode",
  {
    keybindings = {
      -- Playerctl
      {{}, "h", playerctl("previous"), {description = "Previous", group = "Player"}},
      {{}, "j", playerctl("play-pause"), {description = "Play/Pause", group = "Player"}},
      {{}, "k", playerctl("play-pause"), {description = "Play/Pause", group = "Player"}},
      {{}, "l", playerctl("next"), {description = "Next", group = "Player"}},

      -- Volume
      {
        {"Shift"}, "+",
        pactl("set-sink-volume", "@DEFAULT_SINK@", "+5%"),
        {description = "Volume +", group = "Volume"}
      },
      {
        {}, "=",
        pactl("set-sink-volume", "@DEFAULT_SINK@", "+5%"),
        {description = "Volume +", group = "Volume"}
      },
      {
        {}, "-",
        pactl("set-sink-volume", "@DEFAULT_SINK@", "-5%"),
        {description = "Volume -", group = "Volume"}
      },
      {
        {}, "0",
        pactl("set-sink-mute", "@DEFAULT_SINK@", "toggle"),
        {description = "Mute toggle", group = "Volume"}
      }
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
