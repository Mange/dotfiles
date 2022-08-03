-- vim: foldmethod=marker
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
gears = require "gears"
awful = require "awful"
local beautiful = require "beautiful"
naughty = require "naughty"

-- Make AwesomeWM / Lua use the configured locale
os.setlocale(os.getenv "LANG")

require "awful.autofocus"

--
-- Error handling
--
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
  naughty.notify {
    preset = naughty.config.presets.critical,
    title = "Oops, there were errors during startup!",
    text = awesome.startup_errors,
  }
end

-- Handle runtime errors after startup
do
  local in_error = false
  awesome.connect_signal("debug::error", function(err)
    -- Make sure we don't go into an endless error loop
    if in_error then
      return
    end
    in_error = true

    naughty.notify {
      preset = naughty.config.presets.critical,
      title = "Oops, an error happened!",
      text = tostring(err),
    }
    in_error = false
  end)
end

--
-- Theme
--
beautiful.init(require "theme")
require "vendor.bling"
require "module.titlebars"

--
utils = require "utils"
keys = require "keys"
actions = require "actions"
local dropdown = require "dropdown"
local handle_notification = require("module.notification_rules").handle
local fix_missing_icon = require "module.fix_missing_icon"

-- Patch some things in AwesomeWM to make it easier to build things.
require "module.patches"

-- A `require` that reloads the module if it was already loaded.
-- Useful in REPL to be able to test changes to your module without restarting
-- Awesome.
function reload(name)
  package.loaded[name] = nil
  return require(name)
end

--
-- Picom
--
utils.on_first_start(function()
  awful.spawn.once {
    "picom",
    "--config",
    os.getenv "HOME" .. "/.config/picom/picom.conf",
    "--experimental-backends",
  }
end)

require "configuration.screens"
require "layout"
local tags = require("configuration.tags").tags

--
-- Key bindings
--

clientbuttons = gears.table.join(
  awful.button({}, keys.left_click, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
  end),
  awful.button({ keys.modkey }, keys.left_click, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
    awful.mouse.client.move(c)
  end),
  awful.button({ keys.modkey }, keys.right_click, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
    awful.mouse.client.resize(c)
  end)
)

-- Set keys
root.keys(keys.global)

--
-- Notifications
--
naughty.config.defaults.timeout = 10

naughty.config.notify_callback = function(args)
  if handle_notification(args) then
    return args
  else
    return nil
  end
end

--
-- Rules
--
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
  -- All clients will match this rule.
  {
    rule = {},
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      raise = true,
      size_hints_honor = false,
      keys = keys.clientkeys,
      buttons = clientbuttons,
      screen = awful.screen.preferred,
      placement = awful.placement.no_overlap + awful.placement.no_offscreen,
      titlebars_enabled = false,
    },
  },

  -- Floating clients.
  {
    rule_any = {
      instance = {
        "DTA", -- Firefox addon DownThemAll.
        "copyq", -- Includes session name in class.
        "pinentry",
      },
      class = {
        "Arandr",
        "Blueman-manager",
        "Gpick",
        "Kruler",
        "MessageWin", -- kalarm.
        "Sxiv",
        "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
        "Wpa_gui",
        "veromix",
        "xtightvncviewer",
      },

      -- Note that the name property shown in xprop might be set slightly after creation of the client
      -- and the name shown there might not match defined rules here.
      name = {
        "Event Tester", -- xev.
      },
      role = {
        "AlarmWindow", -- Thunderbird's calendar.
        "ConfigManager", -- Thunderbird's about:config.
        "pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
      },
      title = {
        "youtube pip", -- ytpip
      },
    },
    properties = { floating = true, size_hints_honor = true },
  },

  {
    rule = { role = "GtkFileChooserDialog" },
    properties = {
      placement = utils.placement_centered(0.4),
    },
  },

  -- Keyboard viewer
  {
    rule_any = {
      class = { "gkbd-keyboard-display", "Gkbd-keyboard-display" },
    },
    properties = {
      placement = utils.placement_downright(0.5),
      floating = true,
      size_hints_honor = false,
      sticky = true,
      above = true,
      opacity = 0.7,
    },
  },

  -- Notes
  {
    rule_any = {
      class = { "obsidian" },
    },
    properties = { tag = tags[5] },
  },

  -- Media clients
  {
    rule_any = {
      class = { "spotify-tui", "[Ss]potify" },
    },
    properties = { tag = tags[9] },
  },

  -- Game clients
  {
    -- Most Steam windows (friends list, "Activate a new product", "An update
    -- is available", etc.) should be floating…
    rule_any = { class = { "^[Ss]team$" }, title = { "^[Ss]team$" } },
    -- …but not the main window
    exclude_any = {}, -- TODO: Identify the main window
    properties = { floating = true, size_hints_honor = true },
  },
  {
    rule_any = {
      class = { "^[Ss]team$", "^Steam Keyboard$" },
    },
    properties = { tag = tags[8] },
  },

  -- Chat clients
  {
    rule_any = {
      class = { "Slack", "TelegramDesktop", "discord" },
    },
    properties = { tag = tags[10] },
  },
}
dropdown.add_rules(awful.rules.rules)

--
-- Daemons
--
-- Start daemons
require "daemons"

--
-- Signals
--
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
  -- New windows should be made into slaves, not the new master.
  if not awesome.startup then
    awful.client.setslave(c)
  end

  if c.class ~= nil then
    fix_missing_icon(c)
  else
    -- Some clients, most notably Spotify, will not set a class at startup and
    -- will instead assign it later. Detect when new clients are missing a
    -- class and set up an event listener to them to react when a class is
    -- later assigned. Minimize the client initially to prevent screen flashes
    -- until it is ready.
    c.minimized = true
    c:connect_signal("property::class", function()
      c.minimized = false
      awful.rules.apply(c)
      fix_missing_icon(c)
    end)
  end

  if
    awesome.startup
    and not c.size_hints.user_position
    and not c.size_hints.program_position
  then
    -- Prevent clients from being unreachable after screen count changes.
    awful.placement.no_offscreen(c)
  end
end)

client.connect_signal("focus", function(c)
  c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
  c.border_color = beautiful.border_normal
end)

--
-- Startup apps
--
utils.on_first_start(function()
  awful.spawn.once "dynamic-startup"
end)

require "module.tag-toast"
