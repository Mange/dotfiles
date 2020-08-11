-- vim: foldmethod=marker
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
actions = require("actions")
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
local gruvbox = require("colors").gruvbox

beautiful.bg_normal     = gruvbox.dark2
beautiful.bg_focus      = gruvbox.neutral_purple
beautiful.bg_urgent     = gruvbox.bright_red
beautiful.bg_minimize   = gruvbox.dark2
beautiful.bg_systray    = gruvbox.dark3 -- Looks horrible

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

beautiful.wibar_border_width = 0
beautiful.wibar_bg = gruvbox.dark0 .. "55"
beautiful.wibar_fg = gruvbox.light1

beautiful.taglist_bg_focus = gruvbox.faded_purple .. "cc"
beautiful.taglist_bg_urgent = gruvbox.faded_orange .. "55"

beautiful.tasklist_bg_normal = "transparent"
beautiful.tasklist_bg_focus = gruvbox.faded_purple .. "cc"
beautiful.tasklist_bg_urgent = gruvbox.faded_orange .. "55"

beautiful.wallpaper = gears.filesystem.get_xdg_data_home() .. "wallpapers/current.jpg"
-- }}}

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

actions.tags = tags
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

-- {{{ Notifications
naughty.config.defaults.timeout = 10
beautiful.notification_icon_size = utils.dpi(96)
beautiful.notification_bg = gruvbox.dark0.."99"

naughty.config.notify_callback = function(args)
  -- Google Calendar notifications from Firefox looks like this:
  --    title = "<Meeting title>"
  --    text = "09:00 - 09:30"
  --    appname = "Firefox Developer Edition"
  -- Try to match this
  if
    args.appname == "Firefox Developer Edition" and
    string.find(args.text, "^%d%d:%d%d")
  then
    -- Never time out!
    args.timeout = 0
  end

  -- Spotify notifications are not important and should disappear quickly.
  if args.appname == "Spotify" then
    args.timeout = 2
  end

  return args
end
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
        },
        title = {
          "youtube pip", -- ytpip
        },
      }, properties = { floating = true, size_hints_honor = true }},

    {
      rule = {role = "GtkFileChooserDialog"},
      properties = {
        placement = utils.placement_centered(0.4),
      },
    },

    -- Web clients
    {
      rule_any = {
        class = {"Firefox"},
      },
      properties = { tag = tags[3] },
    },

    -- Media clients
    {
      rule_any = {
        class = {"spotify-tui", "[Ss]potify"},
      },
      properties = { tag = tags[9] },
    },

    -- Game clients
    {
      -- Most Steam windows (friends list, "Activate a new product", "An update
      -- is available", etc.) should be floating…
      rule_any = {class = {"^[Ss]team$"}, title = {"^[Ss]team$"}},
      -- …but not the main window
      exclude_any = {}, -- TODO: Identify the main window
      properties = { floating = true, size_hints_honor = true },
    },
    {
      rule_any = {
        class = {"^[Ss]team$", "^Steam Keyboard$"},
      },
      properties = { tag = tags[8] },
    },

    -- Chat clients
    {
      rule_any = {
        class = {"Slack", "TelegramDesktop", "discord"},
      },
      properties = { tag = tags[10] },
    },
}
dropdown.add_rules(awful.rules.rules)
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    -- Some clients, most notably Spotify, will not set a class at startup and
    -- will instead assign it later. Detect when new clients are missing a
    -- class and set up an event listener to them to react when a class is
    -- later assigned. Minimize the client initially to prevent screen flashes
    -- until it is ready.
    if c.class == nil then
      c.minimized = true
      c:connect_signal("property::class", function()
        c.minimized = false
        awful.rules.apply(c)
      end)
    end

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

-- {{{ Startup apps
utils.on_first_start(function()
  awful.spawn.once("dynamic-startup")
end)
-- }}}
