local wibox = require("wibox") -- Widget and layout library
local gears = require("gears")
local awful = require("awful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local keys = require("keys")
local taglist = require("wibar/taglist")
local tasklist = require("wibar/tasklist")
local polybar_wrapper = require("wibar/polybar_wrapper")

local wibar = {}

local function spawn(cmd)
  return function()
    awful.spawn(cmd)
  end
end

local polybar_dir = "/home/mange/.config/polybar/"

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
--  [toggl]
--  [tasks]
--  [battery]
--  [network]
--  [workwave]
--  [systray]
--

-- Create a textclock widget
local time_widget = wibox.widget.textclock(" %a %d %b (v%V)", 30)

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
            spacing = 2,
            s.mytaglist,
            {
              layout = wibox.container.margin,
              margins = 5,
              s.mylayoutbox,
            },
            s.mytasklist,
            polybar_wrapper({
              command = {"/home/mange/.config/polybar/media"},
              interval = 5,
              left_click = spawn({"playerctl", "play-pause"}),
              right_click = spawn({"run-or-raise", 'class = "Spotify"', "spotify"}),
            }),
        },
        { -- Middle widgets
          layout = wibox.layout.fixed.horizontal,
          spacing = 2,
          polybar_wrapper({
            command = {polybar_dir .. "clock"},
            interval = 30,
          }),
          time_widget,
        },
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            spacing = 2,
            polybar_wrapper({
              command = {polybar_dir .. "toggl", "watch", "10"},
              interval = 0,
              left_click = spawn({polybar_dir .. "toggl", "notify"}),
              right_click = spawn({polybar_dir .. "toggl", "start-stop"}),
              middle_click = spawn({"toggle-dropdown", "Toggle Desktop", "toggldesktop"}),
            }),
            polybar_wrapper({
              command = {polybar_dir .. "task-counters"},
              interval = 60,
              left_click = spawn({"kitty", "vit"}),
              right_click = spawn({"kitty", "vit"}),
            }),
            polybar_wrapper({
              command = {polybar_dir .. "mailboxes"},
              interval = 30,
              left_click = spawn({"kitty", "neomutt"}),
              right_click = spawn({"systemctl", "--user", "start", "mailboxes.service"}),
            }),
            wibox.widget.systray(),
        },
      }
  }
end

return wibar
