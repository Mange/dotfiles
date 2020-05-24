-- Setup and configure titlebars
local gears = require("gears")
local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox") -- Widget and layout library

local keys = require("keys")

local function smart_titlebars(c)
  if c.floating or (c.first_tag and c.first_tag.layout.name == "floating") then
    if c.titlebar == nil then
      c:emit_signal("request::titlebars", "rules", {})
    end
    c.border_width = 0
    awful.titlebar.show(c, "left")
  else
    awful.titlebar.hide(c, "left")
    c.border_width = beautiful.border_width
  end
end

-- Manage newly created clients and clients that had their floating status toggled.
client.connect_signal("manage", smart_titlebars)
client.connect_signal("property::floating", smart_titlebars)

-- When switching layouts, also toggle titlebar dynamically.
tag.connect_signal("property::layout", function (t)
  local clients = t:clients()
  for _, client in pairs(clients) do
    smart_titlebars(client)
  end
end)

-- Configure how titlebars are built when they are used
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({}, keys.left_click, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({}, keys.right_click, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c, {position = "left"}) : setup {
      {
        {
          awful.titlebar.widget.iconwidget(c),
          awful.titlebar.widget.ontopbutton(c) ,
          awful.titlebar.widget.stickybutton(c) ,
          awful.titlebar.widget.closebutton(c),
          layout = wibox.layout.fixed.vertical,
          spacing = 7
        },
        layout = wibox.container.margin,
        top = 20,
        bottom = 20
      },
      buttons = buttons,
      layout = wibox.layout.fixed.vertical
    }
end)
