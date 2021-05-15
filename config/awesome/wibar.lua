local wibox = require("wibox") -- Widget and layout library
local gears = require("gears")
local awful = require("awful")

local utils = require("utils")
local keys = require("keys")
local actions = require("actions")
local dpi = require('utils').dpi

--
-- OLD WIDGETS
--
local taglist = require("wibar/taglist")
local polybar_wrapper = require("wibar/polybar_wrapper")
local battery_widget = require("wibar/battery_widget")
local volume_widget = require("wibar/volume_widget")
-- local workrave_widget = require("wibar/workrave_widget")

--
-- NEW WIDGETS
--
local tasklist = require("widgets.tasklist")

local function build_widget(widget)
  return wibox.widget {
    widget = wibox.container.margin,
    top = dpi(9),
    bottom = dpi(9),
    {
      widget = wibox.container.margin,
      border_width = dpi(1),
      border_color = beautiful.groups.title_bg,
      bg = beautiful.transparent,
      shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, dpi(12))
      end,
      widget,
    }
  }
end

local wibar = {}

local polybar_dir = "/home/mange/.config/awesome/polybar_scripts/"

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

  -- Create the wibox
  s.mywibox = awful.wibar({ position = "top", screen = s, height = utils.dpi(32) })

  -- Add widgets to the wibox
  s.mywibox:setup {
      layout = wibox.container.margin,
      margins = utils.dpi(2),
      {
        layout = wibox.layout.align.horizontal,
        expand = "none",
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            spacing = 2,
            s.mytaglist,
            {
              layout = wibox.container.margin,
              margins = 5,
              s.mylayoutbox,
            },
            build_widget(tasklist(s)),
            polybar_wrapper({
              command = {"/home/mange/.config/awesome/polybar_scripts/media"},
              interval = 5,
              left_click = actions.spawn({"playerctl", "play-pause"}),
              right_click = actions.spawn({"run-or-raise", 'class = "Spotify"', "spotify"}),
            }),
        },
        { -- Middle widgets
          layout = wibox.layout.fixed.horizontal,
          spacing = 2,
          polybar_wrapper({
            command = {polybar_dir .. "clock"},
            interval = 30,
          }),
          -- workrave_widget.new(),
        },
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            spacing = 2,
            polybar_wrapper({
              command = {polybar_dir .. "toggl", "watch", "10"},
              interval = 0,
              left_click = actions.spawn({polybar_dir .. "toggl", "notify"}),
              right_click = actions.spawn({polybar_dir .. "toggl", "start-stop"}),
              middle_click = actions.spawn({"toggle-dropdown", "Toggle Desktop", "toggldesktop"}),
            }),
            polybar_wrapper({
              command = {polybar_dir .. "task-counters"},
              interval = 60,
              left_click = actions.spawn({"kitty", "vit"}),
              right_click = actions.spawn({"kitty", "vit"}),
            }),
            volume_widget.new(),
            battery_widget.new(),
            wibox.widget.systray(),
        },
      }
  }
end

return wibar
