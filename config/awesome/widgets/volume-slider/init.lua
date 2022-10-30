local wibox = require "wibox"
local gears = require "gears"
local awful = require "awful"
local beautiful = require "beautiful"
local clickable_container = require "widgets.clickable-container"

local utils = require "utils"
local dpi = utils.dpi
local icons = require "theme.icons"
local volume = require "module.daemons.volume"
local actions = require "actions"
local keys = require "keys"

local action_name = wibox.widget {
  text = "Volume",
  font = beautiful.font_bold_size(10),
  align = "left",
  widget = wibox.widget.textbox,
}

local icon_widget = wibox.widget {
  image = icons.volume_medium,
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
    id = "volume_slider",
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

local volume_slider = slider.volume_slider

volume_slider:buttons(
  gears.table.join(
    awful.button({}, keys.scroll_up, nil, actions.volume_change "+5"),
    awful.button({}, keys.scroll_down, nil, actions.volume_change "-5")
  )
)

-- Triggered both when dragging on the component, and when value is set
-- programmatically. This leads to all kinds of issues, both with volumes >
-- 100% and when you get infinite loops because of rounding errors, etc.
--
-- Guard against that by not reacting on this signal while reacting on some
-- other signal.
local is_handling_callback = false
volume_slider:connect_signal("property::value", function(_, value)
  if not is_handling_callback then
    is_handling_callback = true
    actions.volume_set_now(value)
    is_handling_callback = false
  end
end)

local refresh = function(data)
  is_handling_callback = true

  volume_slider:set_value(utils.clamp(0, data.volume_left, 100))
  local icon
  if data.is_mute then
    icon = icons.volume_off
  elseif data.volume_left < 40 then
    icon = icons.volume_low
  elseif data.volume_left < 80 then
    icon = icons.volume_medium
  else
    icon = icons.volume_high
  end
  icon_widget:set_image(icon)

  is_handling_callback = false
end
volume:on_update(refresh)
refresh(volume)

action_level:buttons(
  awful.util.table.join(awful.button({}, 1, nil, actions.volume_mute_toggle()))
)

local volume_setting = wibox.widget {
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

return { widget = volume_setting }
