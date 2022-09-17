local awful = require "awful"
local nice = require "vendor.nice"

nice {
  titlebar_items = {
    left = { "sticky", "ontop", "floating" },
    middle = "title",
    right = { "maximize", "minimize", "close" },
  },
}

client.connect_signal("property::floating", function(c)
  -- maximized or fullscreen is technically floating, but we don't want titlebars on them
  if c.maximized or c.fullscreen then
    awful.titlebar.hide(c, "top")
  elseif c.floating then
    awful.titlebar.show(c, "top")
  else
    awful.titlebar.hide(c, "top")
  end
end)
