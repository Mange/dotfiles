local wibox = require("wibox") -- Widget and layout library
local gears = require("gears")
local awful = require("awful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local keys = require("keys")
local taglist = require("wibar/taglist")
local tasklist = require("wibar/tasklist")

local wibar = {}

--
-- Bar plan:
--  [tags]
--  [layout indicator]
--  [client icons]
--
--  [clock]
--  [date]
--
--  [media]?
--  [volume]
--  [togglr]
--  [tasks]
--  [battery]
--  [network]
--  [workwave]
--  [systray]
--

-- Create a textclock widget
local time_widget = wibox.widget.textclock("%H:%M   %a %d %b (v%V)", 30)

function wibar.create_for_screen(s)
  -- Create an imagebox widget which will contain an icon indicating which layout we're using.
  -- We need one layoutbox per screen.
  s.mylayoutbox = awful.widget.layoutbox(s)
  s.mylayoutbox:buttons(gears.table.join(
                         awful.button({ }, keys.left_click, function () awful.layout.inc( 1) end),
                         awful.button({ }, keys.right_click, function () awful.layout.inc(-1) end),
                         awful.button({ }, keys.scroll_up, function () awful.layout.inc( 1) end),
                         awful.button({ }, keys.scroll_down, function () awful.layout.inc(-1) end)))

  -- Create a taglist widget
  s.mytaglist = taglist(s)

  -- Create a tasklist widget
  s.mytasklist = tasklist(s)

  -- Create the wibox
  s.mywibox = awful.wibar({ position = "top", screen = s, height = dpi(32) })

  -- Add widgets to the wibox
  s.mywibox:setup {
      layout = wibox.container.margin,
      margins = dpi(2),
      {
        layout = wibox.layout.align.horizontal,
        expand = "none",
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
            s.mylayoutbox,
            s.mytasklist,
        },
        { -- Middle widgets
          layout = wibox.layout.fixed.horizontal,
          time_widget,
        },
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.systray(),
        },
      }
  }
end

return wibar
