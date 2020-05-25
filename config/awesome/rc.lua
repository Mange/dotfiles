-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
gears = require("gears")
awful = require("awful")
beautiful = require("beautiful") -- Theme handling library
naughty = require("naughty") -- Notification library

require("awful.autofocus")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

utils = require("utils")
keys = require("keys")
local dropdown = require("dropdown")
local sharedtags = require("sharedtags")
local wibar = require("wibar")

-- {{{ Variable definitions
-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    -- awful.layout.suit.floating,     -- All windows are floating
    awful.layout.suit.tile,            -- Master + Stack, with Master on Left
    awful.layout.suit.tile.left,       -- Master + Stack, with Master on Right
    -- awful.layout.suit.tile.bottom,  -- Master + Stack, with Master on Bottom
    awful.layout.suit.tile.top,        -- Master + Stack, with Master on Top
    awful.layout.suit.fair,            -- Grid (Vertical)
    awful.layout.suit.fair.horizontal, -- Grid (Horizontal)
    -- awful.layout.suit.spiral,       -- Fibonacci
    awful.layout.suit.spiral.dwindle,  -- BSP
    awful.layout.suit.max,             -- "Tabbed"
    -- awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,       -- Master floating center
    -- awful.layout.suit.corner.nw,    -- Master + two stacks below and to the side
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Theme
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

beautiful.font = "Fira Sans Regular 11"

-- Setup gaps
beautiful.useless_gap = 8
beautiful.gap_single_client = false

-- Colors
gruvbox = {
  dark0_hard = "#1d2021",
  dark0 = "#282828",
  dark0_soft = "#32302f",
  dark1 = "#3c3836",
  dark2 = "#504945",
  dark3 = "#665c54",
  dark4 = "#7c6f64",
  dark4_256 = "#7c6f64",

  gray_245 = "#928374",
  gray_244 = "#928374",

  light0_hard = "#f9f5d7",
  light0 = "#fbf1c7",
  light0_soft = "#f2e5bc",
  light1 = "#ebdbb2",
  light2 = "#d5c4a1",
  light3 = "#bdae93",
  light4 = "#a89984",
  light4_256 = "#a89984",

  bright_red = "#fb4934",
  bright_green = "#b8bb26",
  bright_yellow = "#fabd2f",
  bright_blue = "#83a598",
  bright_purple = "#d3869b",
  bright_aqua = "#8ec07c",
  bright_orange = "#fe8019",

  neutral_red = "#cc241d",
  neutral_green = "#98971a",
  neutral_yellow = "#d79921",
  neutral_blue = "#458588",
  neutral_purple = "#b16286",
  neutral_aqua = "#689d6a",
  neutral_orange = "#d65d0e",

  faded_red = "#9d0006",
  faded_green = "#79740e",
  faded_yellow = "#b57614",
  faded_blue = "#076678",
  faded_purple = "#8f3f71",
  faded_aqua = "#427b58",
  faded_orange = "#af3a03"
}

beautiful.bg_normal     = gruvbox.dark3
beautiful.bg_focus      = gruvbox.neutral_purple
beautiful.bg_urgent     = gruvbox.bright_red
beautiful.bg_minimize   = gruvbox.dark3
beautiful.bg_systray    = beautiful.bg_normal

beautiful.fg_normal     = gruvbox.light1
beautiful.fg_focus      = gruvbox.light0
beautiful.fg_urgent     = gruvbox.light1
beautiful.fg_minimize   = gruvbox.light1

beautiful.border_width  = 3
beautiful.border_normal = gruvbox.dark3
beautiful.border_focus  = gruvbox.neutral_purple
beautiful.border_marked = gruvbox.faded_yellow

beautiful.titlebar_bg_normal = gruvbox.dark3 .. "70"
beautiful.titlebar_bg_focus  = gruvbox.neutral_purple .. "70"

beautiful.wallpaper = gears.filesystem.get_xdg_data_home() .. "wallpapers/current.jpg"
-- }}}
--

-- {{{ Tags
tags = sharedtags({
    {
      name = "System",
      icon_text = "",
      layout = awful.layout.suit.tile
    },
    {
      name = "Code",
      icon_text = "",
      layout = awful.layout.suit.tile
    },
    {
      name = "Browse",
      icon_text = "",
      layout = awful.layout.suit.tile
    },
    {
      name = "4",
      icon_text = nil,
      layout = awful.layout.suit.tile
    },
    {
      name = "5",
      icon_text = nil,
      layout = awful.layout.suit.tile
    },
    {
      name = "6",
      icon_text = nil,
      layout = awful.layout.suit.tile
    },
    {
      name = "7",
      icon_text = nil,
      layout = awful.layout.suit.tile
    },
    {
      name = "Game",
      icon_text = "",
      layout = awful.layout.suit.max
    },
    {
      name = "Media",
      icon_text = "",
      layout = awful.layout.suit.fair.horizontal,
      screen = 2
    },
    {
      name = "Chat",
      icon_text = "",
      layout = awful.layout.suit.max,
      screen = 2
    },
})

keys.tags = tags
-- }}}

-- {{{ Screens

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", utils.reload_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    utils.reload_wallpaper(s)

    wibar.create_for_screen(s)
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, keys.scroll_up, awful.tag.viewnext),
    awful.button({ }, keys.scroll_down, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings

clientbuttons = gears.table.join(
    awful.button({ }, keys.left_click, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ keys.modkey }, keys.left_click, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ keys.modkey }, keys.right_click, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(keys.global)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     size_hints_honor = false,
                     keys = keys.clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen,
                     titlebars_enabled = false,
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
dropdown.add_rules(awful.rules.rules)
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Components
local config_dir = awful.util.getdir("config")
dofile(config_dir .. "/titlebars.lua")
-- }}}

-- {{{ Startup apps
utils.on_first_start(function()
  awful.spawn.once("dynamic-startup")
end)
-- }}}
