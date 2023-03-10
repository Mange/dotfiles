local awful = require "awful"
local nice = require "vendor.nice"

nice {
  titlebar_items = {
    left = { "sticky", "ontop", "floating" },
    middle = "title",
    right = { "maximize", "minimize", "close" },
  },
}

local function on_floating_toggle(c)
  -- If titlebars_enabled is set to explicitly false, then don't use titlebars.
  local should_have_titlebars = (c.titlebars_forbidden ~= true)
    and c.floating
    -- maximized or fullscreen is technically floating, but we don't want
    -- titlebars on them
    and not (c.maximized or c.fullscreen)

  if should_have_titlebars then
    awful.titlebar.show(c, "top")
  else
    awful.titlebar.hide(c, "top")
  end
end

local M = {}

function M.module_initialize()
  client.connect_signal("property::floating", on_floating_toggle)

  return function()
    client.disconnect_signal("property::floating", on_floating_toggle)
  end
end

return M
