local gears = require("gears")
local awful = require("awful")
local utils = require("utils")

local battery_dir = "/sys/class/power_supply/BAT0"

local function read_battery_data(name, format)
  local file = io.open(battery_dir .. "/" .. name, "r")
  if file then
    local contents = file:read(format)
    file:close()
    return contents
  end
end

---@return boolean
local function has_battery()
  return gears.filesystem.is_dir(battery_dir)
end

local battery_info = {
  has_battery = has_battery(),
}

function battery_info.update()
  ---@type number
  local capacity = read_battery_data("capacity", "n")
  ---@type string
  local status = read_battery_data("status", "*l")

  awesome.emit_signal("mange:battery:update", {
    real = true,
    percent = capacity,
    full = status == "Full",
    charging = status == "Charging",
    discharging = status == "Discharging",
  })
end

---@param callback function(string): void
function battery_info.describe_state(callback)
  awful.spawn.easy_async({"acpi"}, function(stdout)
    callback(utils.strip(stdout))
  end)
end

if has_battery() then
  gears.timer {
    timeout = 10,
    call_now = true,
    autostart = true,
    callback = battery_info.update
  }
else
  ---@class BatteryInfo
  ---@type BatteryInfo
  local info = {
    real = false,
    percent = 100,
    full = true,
    charging = true,
    discharging = false
  }
  awesome.emit_signal("mange:battery:update", info)
end

return battery_info
