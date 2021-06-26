local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")

local clickable_container = require("widgets.clickable-container")
local battery = require("daemons.battery")
local dpi = require("utils").dpi

local widget_icon_dir = gears.filesystem.get_configuration_dir() .. "widgets/battery/icons/"

local battery_indicator = function()
  local imagebox = wibox.widget {
    layout = wibox.layout.align.vertical,
    expand = "none",
    nil,
    {
      id = "icon",
      image = widget_icon_dir .. "battery.svg",
      widget = wibox.widget.imagebox,
      resize = true
    },
    nil,
  }

  local text = wibox.widget {
    widget = wibox.widget.textbox,
    id = "percent_text",
    text = "100%",
    font = beautiful.font_bold_size(11),
    align = "center",
    valign = "center",
    visible = false,
  }


  local battery_widget = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    spacing = dpi(0),
    imagebox,
    text
  }


  local battery_button = wibox.widget {
    {
      battery_widget,
      margins = dpi(7),
      widget = wibox.container.margin
    },
    widget = clickable_container
  }

  local battery_tooltip =  awful.tooltip {
    objects = {battery_button},
    text = "None",
    mode = "outside",
    align = "right",
    margin_leftright = dpi(8),
    margin_topbottom = dpi(8),
    preferred_positions = {"right", "left", "top", "bottom"}
  }

  awesome.connect_signal(
    "mange:battery:update",
    ---@param info BatteryInfo
    function(info)
      local icon_name

      if info.real then
        battery_widget.spacing = dpi(5)
        text.visible = true
        text:set_text(tostring(info.percent) .. "%")

        if info.full then
          icon_name = "battery-fully-charged.svg"
        elseif info.discharging and info.percent < 10 then
          icon_name = "battery-alert-red.svg"
        else
          icon_name = "battery-"
          if info.charging then
            icon_name = icon_name .. "charging-"
          else
            icon_name = icon_name .. "discharging-"
          end
          if info.percent < 20 then
            icon_name = icon_name .. "10.svg"
          elseif info.percent < 30 then
            icon_name = icon_name .. "20.svg"
          elseif info.percent < 40 then
            icon_name = icon_name .. "30.svg"
          elseif info.percent < 60 then
            icon_name = icon_name .. "50.svg"
          elseif info.percent < 70 then
            icon_name = icon_name .. "60.svg"
          elseif info.percent < 90 then
            icon_name = icon_name .. "80.svg"
          else
            icon_name = icon_name .. "90.svg"
          end
        end
      else
        battery_widget.spacing = 0
        text.visible = false
        icon_name = "battery-unknown.svg"
      end

      if icon_name then
        imagebox.icon:set_image(widget_icon_dir .. icon_name)
      end
    end
  )

local function load_battery_tooltip()
  battery_tooltip:set_text("Laddar…")
  battery.describe_state(function(description)
    battery_tooltip:set_text(description)
  end)
end

  battery.update()

  battery_widget:connect_signal(
    "mouse::enter",
    function()
      battery.update()
      load_battery_tooltip()
    end
  )

  return battery_button
end

return battery_indicator
