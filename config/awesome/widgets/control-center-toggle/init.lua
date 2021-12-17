local awful = require "awful"
local wibox = require "wibox"
local gears = require "gears"

local dpi = require("utils").dpi
local keys = require "keys"

local config_dir = gears.filesystem.get_configuration_dir()
local widget_icon_dir = config_dir .. "widgets/control-center-toggle/icons/"
local clickable_container = require "widgets.clickable-container"

local control_center_toggle = function(s)
  local widget = wibox.widget {
    layout = wibox.layout.align.horizontal,
    {
      image = widget_icon_dir .. "control-center.svg",
      widget = wibox.widget.imagebox,
      resize = true,
    },
  }

  local widget_button = wibox.widget {
    widget = clickable_container,
    {
      widget,
      margins = dpi(7),
      widget = wibox.container.margin,
    },
  }

  widget_button:buttons(
    gears.table.join(awful.button({}, keys.left_click, nil, function()
      if s.control_center then
        s.control_center:toggle()
      end
    end))
  )

  return widget_button
end

return control_center_toggle
