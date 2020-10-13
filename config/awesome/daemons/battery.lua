local gears = require("gears")

local battery_dir = "/sys/class/power_supply/BAT0"

local function read_battery_data(name, format)
  local file = io.open(battery_dir .. "/" .. name, "r")
  if file then
    local contents = file:read(format)
    file:close()
    return contents
  end
end

local function has_battery()
  return gears.filesystem.is_dir(battery_dir)
end

local function refresh()
  local capacity = read_battery_data("capacity", "n")
  local status = read_battery_data("status", "*l")
  awesome.emit_signal("mange:battery:update", {
    real = true,
    percent = capacity,
    full = status == "Full",
    charging = status == "Charging",
    discharging = status == "Discharging",
  })
end

if has_battery() then
  gears.timer {
    timeout = 10,
    call_now = true,
    autostart = true,
    callback = refresh
  }
else
  awesome.emit_signal("mange:battery:update", {
    real = false,
    percent = 100,
    full = true,
    charging = true,
    discharging = false
  })
end
