local wibox = require "wibox"
local beautiful = require "beautiful"

local clickable_container = function(widget, options)
  local container = wibox.widget {
    widget = wibox.container.background,
    widget,
  }
  options = options or {}
  local on_mouse_enter = options.on_mouse_enter or function() end
  local on_mouse_leave = options.on_mouse_leave or function() end

  -- Store references from mouse::enter for mouse::leave to be able to clean everything up.
  local old_cursor, old_hovered

  container:connect_signal("mouse::enter", function()
    container.bg = beautiful.groups.bg
    local hovered = mouse.current_wibox
    if hovered then
      old_cursor, old_hovered = hovered.cursor, hovered
      -- cursor names: https://awesomewm.org/doc/api/libraries/root.html#cursor
      hovered.cursor = "hand2" -- pointing hand
    end
    on_mouse_enter()
  end)

  container:connect_signal("mouse::leave", function()
    container.bg = beautiful.events.leave
    if old_hovered then
      old_hovered.cursor = old_cursor
      old_hovered = nil
    end
    on_mouse_leave()
  end)

  container:connect_signal("button::press", function()
    container.bg = beautiful.events.press
  end)

  container:connect_signal("button::release", function()
    container.bg = beautiful.events.release
  end)

  return container
end

return clickable_container
