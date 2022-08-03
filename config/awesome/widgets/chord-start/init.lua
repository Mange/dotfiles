local awful = require "awful"
local wibox = require "wibox"
local gears = require "gears"

local dpi = require("utils").dpi
local keys = require "keys"
local icons = require "theme.icons"

local clickable_container = require "widgets.clickable-container"

local widget = wibox.widget {
  layout = wibox.layout.align.horizontal,
  {
    image = icons.circle_dot,
    widget = wibox.widget.imagebox,
    resize = true,
  },
}

local chord_start = wibox.widget {
  widget = clickable_container,
  {
    widget,
    margins = dpi(7),
    widget = wibox.container.margin,
  },
}

chord_start:buttons(
  gears.table.join(awful.button({}, keys.left_click, nil, function()
    keys.awesome_chord.enter()
  end))
)

return chord_start
