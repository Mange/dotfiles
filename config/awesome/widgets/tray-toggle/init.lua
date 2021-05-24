local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi
local clickable_container = require("widgets.clickable-container")
local config_dir = gears.filesystem.get_configuration_dir()
local widget_icon_dir = config_dir .. "widgets/tray-toggle/icons/"

local widget = wibox.widget {
  {
    id = "icon",
    image = widget_icon_dir .. "left-arrow" .. ".svg",
    widget = wibox.widget.imagebox,
    resize = true
  },
  layout = wibox.layout.align.horizontal
}

local widget_button = wibox.widget {
  {
    widget,
    margins = dpi(7),
    widget = wibox.container.margin
  },
  widget = clickable_container
}

local refresh = function(systray)
  if systray then
    if systray.visible then
      widget.icon:set_image(gears.surface.load_uncached(widget_icon_dir .. "left-arrow.svg"))
    else
      widget.icon:set_image(gears.surface.load_uncached(widget_icon_dir .. "right-arrow.svg"))
    end
  end
end

widget_button:buttons(
  gears.table.join(
    awful.button(
      {},
      1,
      nil,
      function()
        awesome.emit_signal("widget::systray:toggle")
      end
    )
  )
)

-- Listen to signal
awesome.connect_signal(
  "widget::systray:toggle",
  function()
    if screen.primary.systray then
      screen.primary.systray.visible = not screen.primary.systray.visible
      refresh(screen.primary.systray)
    end
  end
)

-- Update icon on start-up
if screen.primary.systray then
  refresh(screen.primary.systray)
end

-- Show only the tray button in the primary screen
return awful.widget.only_on_screen(widget_button, "primary")
