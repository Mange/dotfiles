local timer = require("gears.timer")
local spawn = require("awful.spawn")

local function refresh()
  spawn.easy_async(
    {"pulsemixer", "--get-volume", "--get-mute"},
    function(stdout)
      local volume_left, volume_right, is_mute = string.match(stdout, "(%d)%s+(%d+)%s+(%d+)")
      -- If command fails, don't emit signal.
      if volume_left ~= nil then
        awesome.emit_signal("mange:volume:update", {
          volume_left = tonumber(volume_left),
          volume_right = tonumber(volume_right),
          is_mute = (is_mute == "1"),
        })
      end
    end
  )
end

-- Spawn a watcher of pulseaudio daemon to refresh the widget every time
-- something changed on the server or on a sink. Server changes include
-- changing default sink, for example. Sink changes are usually volume or mute
-- status.
local function spawn_watcher()
  local cmd = [[
    sh -c '
      LC_ALL=C pactl subscribe | grep --line-buffered -E "Event .change. on (sink|server) "
    '
  ]]
  return spawn.with_line_callback(cmd, {
      stdout = function(_)
        refresh()
      end,
      stderr = function(_)
        refresh()
      end,
    })
end

spawn_watcher()

-- Have an independent timer that refreshes every 30 seconds, in case the
-- watcher malfunctions for some reason.
timer {
  timeout = 30,
  call_now = true,
  autostart = true,
  callback = refresh
}
