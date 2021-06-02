local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

local dpi = require("utils").dpi
local clickable_container = require("widgets.clickable-container")
local icons = require("theme.icons")
local actions = require("actions")

local end_session = function()
  local widget = wibox.widget {
    {
      id = "icon",
      image = icons.power,
      resize = true,
      widget = wibox.widget.imagebox
    },
    layout = wibox.layout.align.horizontal
  }

  local widget_button = wibox.widget {
    {
      {
        widget,
        margins = dpi(5),
        widget = wibox.container.margin
      },
      widget = clickable_container
    },
    bg = beautiful.transparent,
    shape = gears.shape.circle,
    widget = wibox.container.background
  }

  widget_button:buttons(
    gears.table.join(
      awful.button(
        {},
        1,
        nil,
        actions.compose(
          actions.close_control_center(),
          actions.log_out()
        )
      )
    )
  )

  return widget_button
end

return end_session
