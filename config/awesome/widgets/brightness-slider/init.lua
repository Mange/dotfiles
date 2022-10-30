local wibox = require "wibox"
local gears = require "gears"
local awful = require "awful"
local beautiful = require "beautiful"
local clickable_container = require "widgets.clickable-container"

local utils = require "utils"
local dpi = utils.dpi
local icons = require "theme.icons"
local brightness = require "module.daemons.brightness"
local actions = require "actions"
local keys = require "keys"

local action_name = wibox.widget {
  text = "Brightness",
  font = beautiful.font_bold_size(10),
  align = "left",
  widget = wibox.widget.textbox,
}

local icon_widget = wibox.widget {
  image = icons.brightness,
  resize = true,
  widget = wibox.widget.imagebox,
}

local action_level = wibox.widget {
  widget = wibox.container.background,
  bg = beautiful.groups.bg,
  shape = beautiful.groups.shape,
  {
    widget = clickable_container,
    {
      margins = dpi(5),
      widget = wibox.container.margin,
      {
        layout = wibox.layout.align.vertical,
        expand = "none",
        nil,
        icon_widget,
        nil,
      },
    },
  },
}

local slider = wibox.widget {
  layout = wibox.layout.align.vertical,
  expand = "none",
  forced_height = dpi(24),
  nil,
  {
    id = "brightness_slider",
    widget = wibox.widget.slider,
    bar_shape = gears.shape.rounded_rect,
    bar_height = dpi(24),
    bar_color = "#ffffff20",
    bar_active_color = "#f2f2f2EE",
    handle_color = "#ffffff",
    handle_shape = gears.shape.circle,
    handle_width = dpi(24),
    handle_border_color = "#00000012",
    handle_border_width = dpi(1),
    maximum = 100,
  },
  nil,
}

local brightness_slider = slider.brightness_slider

brightness_slider:buttons(
  gears.table.join(
    awful.button({}, keys.scroll_up, nil, actions.brightness_change "+5%"),
    awful.button({}, keys.scroll_down, nil, actions.brightness_change "5%-")
  )
)

-- Triggered both when dragging on the component, and when value is set
-- programmatically. This leads to all kinds of issues, both with brightness >
-- 100% and when you get infinite loops because of rounding errors, etc.
--
-- Guard against that by not reacting on this signal while reacting on some
-- other signal.
local is_handling_callback = false
brightness_slider:connect_signal("property::value", function(_, value)
  if not is_handling_callback then
    is_handling_callback = true
    actions.brightness_change(value .. "%")()
    is_handling_callback = false
  end
end)

local brightness_setting = wibox.widget {
  layout = wibox.layout.fixed.vertical,
  forced_height = dpi(48),
  spacing = dpi(5),
  action_name,
  {
    layout = wibox.layout.fixed.horizontal,
    spacing = dpi(5),
    {
      layout = wibox.layout.align.vertical,
      expand = "none",
      nil,
      {
        layout = wibox.layout.fixed.horizontal,
        forced_height = dpi(24),
        forced_width = dpi(24),
        action_level,
      },
      nil,
    },
    slider,
  },
}

---@param data BrightnessInfo
local refresh = function(data)
  is_handling_callback = true

  brightness_slider:set_value(utils.clamp(0, data.percent, 100))

  is_handling_callback = false
end
brightness:on_update(refresh)
refresh(brightness)

action_level:buttons(awful.util.table.join(awful.button({}, 1, nil, function()
  if brightness.percent < 100 then
    actions.brightness_change "100%"()
  else
    actions.brightness_change "20%"()
  end
end)))

return { widget = brightness_setting }
