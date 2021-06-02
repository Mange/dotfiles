local timer = require("gears.timer")
local spawn = require("awful.spawn")

local volume = {
  volume_left = 0,
  volume_right = 0,
  is_mute = true,
}

function volume:refresh()
  spawn.easy_async(
    {"pulsemixer", "--get-volume", "--get-mute"},
    function(stdout)
      local volume_left, volume_right, is_mute = string.match(stdout, "(%d+)%s+(%d+)%s+(%d+)")
      -- If command fails, don't emit signal.
      if volume_left ~= nil then
        volume.volume_left = tonumber(volume_left)
        volume.volume_right = tonumber(volume_right)
        volume.is_mute = (is_mute == "1")

        awesome.emit_signal("mange:volume:update", volume)
      end
    end
  )
end

function volume:on_update(func)
  awesome.connect_signal("mange:volume:update", func)
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
        volume:refresh()
      end,
      stderr = function(_)
        volume:refresh()
      end,
    })
end

spawn_watcher()

-- Have an independent timer that refreshes every 60 seconds, in case the
-- watcher malfunctions for some reason.
timer {
  timeout = 60,
  call_now = true,
  autostart = true,
  callback = function() volume:refresh() end
}

return volume
