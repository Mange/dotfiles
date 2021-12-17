local timer = require "gears.timer"
local spawn = require "awful.spawn"

---@class BrightnessInfo
local brightness = {
  is_controllable = false,
  current = 0,
  max = 0,
  percent = 0,
}

local function handle_brightness_output(stdout)
  -- Output: "intel_backlight,backlight,24000,40%,60000"
  local current, percent, max = string.match(
    stdout,
    "[%w_]+,[%w_]+,(%d+),(%d+)%%,(%d+)"
  )
  -- If command fails, don't emit signal.
  if max ~= nil then
    brightness.is_controllable = true
    brightness.current = tonumber(current)
    brightness.max = tonumber(max)
    brightness.percent = tonumber(percent)
  else
    brightness.is_controllable = false
    brightness.current = 0
    brightness.max = 0
    brightness.percent = 0
  end
  awesome.emit_signal("mange:brightness:update", brightness)
end

function brightness:refresh()
  spawn.easy_async(
    { "brightnessctl", "--class=backlight", "--machine-readable", "info" },
    handle_brightness_output
  )
end

---@param amount string
function brightness:set(amount)
  awful.spawn.easy_async({ "brightnessctl", "set", amount }, function()
    brightness:refresh()
  end)
end

---@param callback function(BrightnessInfo)
function brightness:on_update(callback)
  awesome.connect_signal("mange:brightness:update", callback)
end

-- Have an independent timer that refreshes every 60 seconds, in case the
-- watcher malfunctions for some reason.
timer {
  timeout = 60,
  call_now = true,
  autostart = true,
  callback = function()
    brightness:refresh()
  end,
}

return brightness
