local wibox = require("wibox")
local beautiful = require("beautiful")

local clickable_container = function(widget)
  local container = wibox.widget {
    widget = wibox.container.background,
    widget,
  }

  -- Store references from mouse::enter for mouse::leave to be able to clean everything up.
  local old_cursor, old_wibox

  container:connect_signal(
    "mouse::enter",
    function()
      container.bg = beautiful.groups.bg
      local wibox = mouse.current_wibox
      if wibox then
        old_cursor, old_wibox = wibox.cursor, wibox
        wibox.cursor = "hand1"
      end
    end
  )

  container:connect_signal(
    "mouse::leave",
    function()
      container.bg = beautiful.events.leave
      if old_wibox then
        old_wibox.cursor = old_cursor
        old_wibox = nil
      end
    end
  )

  container:connect_signal(
    "button::press",
    function()
      container.bg = beautiful.events.press
    end
  )

  container:connect_signal(
    "button::release",
    function()
      container.bg = beautiful.events.release
    end
  )

  return container
end

return clickable_container
