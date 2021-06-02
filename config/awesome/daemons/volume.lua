local timer = require("gears.timer")
local spawn = require("awful.spawn")
local utils = require("utils")

local volume = {
  volume_left = 0,
  volume_right = 0,
  is_mute = true,
}

local function handle_volume_current_output(stdout)
  local volume_left, volume_right, is_mute = string.match(stdout, "(%d+)%s+(%d+)%s+(%d+)")
  -- If command fails, don't emit signal.
  if volume_left ~= nil then
    volume.volume_left = tonumber(volume_left)
    volume.volume_right = tonumber(volume_right)
    volume.is_mute = (is_mute == "1")

    awesome.emit_signal("mange:volume:update", volume)
  end
end

function volume:refresh()
  spawn.easy_async({"volume-current"}, handle_volume_current_output)
end

function volume:on_update(func)
  awesome.connect_signal("mange:volume:update", func)
end

-- Spawn a watcher of pulseaudio daemon to refresh the widget every time
-- something changed on the server or on a sink. Server changes include
-- changing default sink, for example. Sink changes are usually volume or mute
-- status.
local function spawn_watcher()
  return spawn.with_line_callback(
    {"volume-monitor"},
    {stdout = handle_volume_current_output}
  )
end
utils.kill_on_exit(spawn_watcher())

-- Have an independent timer that refreshes every 60 seconds, in case the
-- watcher malfunctions for some reason.
timer {
  timeout = 60,
  call_now = true,
  autostart = true,
  callback = function() volume:refresh() end
}

return volume
