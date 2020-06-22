local wibox = require("wibox")
local beautiful = require("beautiful")
local gears = require("gears")

local gruvbox = require("colors").gruvbox
local utils = require("utils")

local battery_widget = {}
local battery_dir = "/sys/class/power_supply/BAT0"

local service

local function read_battery_data(name, format)
  local file = io.open(battery_dir .. "/" .. name, "r")
  if file then
    local contents = file:read(format)
    file:close()
    return contents
  end
end

local function setup_service()
  if service then
    return service
  end

  service = {}

  service.refresh = function()
    local capacity = read_battery_data("capacity", "n")
    local status = read_battery_data("status", "*l")
    awesome.emit_signal("mange:battery:update", {
      percent = capacity,
      full = status == "Full",
      charging = status == "Charging",
      discharging = status == "Discharging",
    })
  end

  service.timer = gears.timer {
    timeout = 30,
    call_now = true,
    autostart = true,
    callback = service.refresh
  }

  return service
end

local function has_battery()
  return gears.filesystem.is_dir(battery_dir)
end

local function empty_widget()
  return wibox.widget {
    widget = wibox.widget.textbox,
    text = ""
  }
end

function battery_widget.new()
  if not has_battery() then
    return empty_widget()
  end

  local text = wibox.widget {
    widget = wibox.widget.textbox,
    align = "center",
    valign = "center"
  }

  local text_on_bg = wibox.widget {
    widget = wibox.container.background,
    text
  }

  local widget = wibox.widget {
    widget = wibox.container.arcchart,
    max_value = 100,
    rounded_edge = true,
    border_width = 0,
    thickness = utils.dpi(2),
    paddings = 2,
    start_angle = math.rad(270), -- Start on top
    text_on_bg,
  }

  local function update(data)
    widget.value = data.percent
    text.text = data.percent
    widget.visible = not(data.full)

    if data.percent < 10 then
      widget.colors = { gruvbox.bright_red }
    elseif data.percent < 30 then
      widget.colors = { gruvbox.faded_yellow }
    else
      widget.colors = { beautiful.fg_normal }
    end

    if data.discharging then
      text_on_bg.fg = beautiful.fg_normal
      text_on_bg.bg = gruvbox.faded_red .. "55"
    else
      text_on_bg.fg = beautiful.fg_normal
      text_on_bg.bg = gruvbox.faded_green .. "55"
    end
  end

  awesome.connect_signal("mange:battery:update", function(data) update(data) end)
  setup_service()

  return widget
end

return battery_widget
