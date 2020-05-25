local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

local keys = require("keys")

local function view_only(t)
  t:view_only()
end

local function move_client_to_tag(t)
  if client.focus then
    client.focus:move_to_tag(t)
  end
end

local function client_toggle_tag(t)
  if client.focus then
    client.focus:toggle_tag(t)
  end
end

local function next_tag(t)
  awful.tag.viewnext(t.screen)
end

local function previous_tag(t)
  awful.tag.viewprev(t.screen)
end

local taglist_buttons = gears.table.join(
  awful.button({}, keys.left_click, view_only),
  awful.button({keys.modkey}, keys.left_click, move_client_to_tag),
  awful.button({}, keys.right_click, awful.tag.viewtoggle),
  awful.button({keys.modkey}, keys.right_click, client_toggle_tag),
  awful.button({}, keys.scroll_up, next_tag),
  awful.button({}, keys.scroll_down, previous_tag)
)

local function on_tag_widget_create(self, t, index, objects) --luacheck: no unused args
  local icon_text = t.icon_text or t.name
  self:get_children_by_id("icon_text_role")[1].text = icon_text
end

return function(s)
    return awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons,
        widget_template = {
          widget = wibox.container.background,
          id = "background_role",
          create_callback = on_tag_widget_create,
          {
            layout = wibox.container.margin,
            left = 5,
            right = 5,
            {
              widget = wibox.widget.textbox,
              id = "icon_text_role"
            }
          }
        },
    }
end
