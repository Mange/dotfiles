local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox") -- Widget and layout library

local keys = require("keys")

local tasklist_buttons = gears.table.join(
                     awful.button({ }, keys.left_click, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, keys.right_click, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, keys.scroll_up, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, keys.scroll_down, function ()
                                              awful.client.focus.byidx(-1)
                                          end))


return function(s)
  return awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
        widget_template = {
          {
            {
              {
                id = "clienticon",
                widget = awful.widget.clienticon
              },
              margins = 1,
              widget = wibox.container.margin
            },
            id = "background_role",
            widget = wibox.container.background,
          },
          nil,
          create_callback = function(self, c, index, objects) --luacheck: no unused args
            self:get_children_by_id("clienticon")[1].client = c
          end,
          layout = wibox.layout.align.vertical
        }
    }
  end
