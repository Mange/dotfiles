local wibox = require "wibox"
local gears = require "gears"
local awful = require "awful"
local beautiful = require "beautiful"
local clickable_container = require "widgets.clickable-container"

local utils = require "utils"
local dpi = utils.dpi
local icons = require "theme.icons"
local picom = require "daemons.picom"
local actions = require "actions"
local keys = require "keys"

local action_name = wibox.widget {
  text = "Blur strength",
  font = beautiful.font_bold_size(10),
  align = "left",
  widget = wibox.widget.textbox,
}

local icon_widget = wibox.widget {
  image = icons.effects,
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
    id = "blur_strength_slider",
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
    minimum = picom.min_blur_strength,
    maximum = picom.max_blur_strength,
  },
  nil,
}

local blur_slider = slider.blur_strength_slider

blur_slider:buttons(gears.table.join(
  awful.button({}, keys.scroll_up, nil, function()
    picom:change_blur_strength(1)
  end),
  awful.button({}, keys.scroll_down, nil, function()
    picom:change_blur_strength(-1)
  end)
))

-- Triggered both when dragging on the component, and when value is set
-- programmatically.
-- TODO: Only apply after the control is released?
local is_handling_callback = false
blur_slider:connect_signal("property::value", function(_, value)
  if not is_handling_callback then
    is_handling_callback = true
    picom:set_blur_strength(value)
    is_handling_callback = false
  end
end)

local refresh = function(strength)
  is_handling_callback = true
  blur_slider:set_value(
    utils.clamp(picom.min_blur_strength, strength, picom.max_blur_strength)
  )
  is_handling_callback = false
end
picom:on_update_blur_strength(refresh)
refresh(picom.blur_strength)

action_level:buttons(keys.mouse_click({}, keys.left_click, function()
  if picom.blur_strength == picom.min_blur_strength then
    picom:set_blur_strength(picom.default_blur_strength)
  elseif picom.blur_strength == picom.default_blur_strength then
    picom:set_blur_strength(picom.max_blur_strength)
  else
    picom:set_blur_strength(picom.min_blur_strength)
  end
end))

local blur_slider = wibox.widget {
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

return { widget = blur_slider }
