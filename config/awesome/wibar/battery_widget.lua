local wibox = require "wibox"
local beautiful = require "beautiful"

local gruvbox = require("colors").gruvbox
local utils = require "utils"

local battery_widget = {}

function battery_widget.new()
  local text = wibox.widget {
    widget = wibox.widget.textbox,
    align = "center",
    valign = "center",
  }

  local text_on_bg = wibox.widget {
    widget = wibox.container.background,
    text,
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
    widget.visible = not data.full

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

  awesome.connect_signal("mange:battery:update", function(data)
    update(data)
  end)

  return widget
end

return battery_widget
