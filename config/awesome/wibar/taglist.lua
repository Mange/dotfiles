local awful = require("awful")
local gears = require("gears")
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

return function(s)
    return awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }
end
