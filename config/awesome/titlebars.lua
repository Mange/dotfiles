-- Setup and configure titlebars
local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox") -- Widget and layout library

local function smart_titlebars(c)
  if c.floating or (c.first_tag and c.first_tag.layout.name == "floating") then
    awful.titlebar.show(c)
  else
    awful.titlebar.hide(c)
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
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)
