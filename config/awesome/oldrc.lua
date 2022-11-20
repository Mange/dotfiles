-- Standard awesome library
local awful = require "awful"
local beautiful = require "beautiful"
local naughty = require "naughty"

--
local keys = require "keys"
local dropdown = require "dropdown"
local handle_notification = require("module.notification_rules").handle
local fix_missing_icon = require "module.fix_missing_icon"

require "layout"

--
-- Key bindings
--

-- Set keys
-- (Will overwrite the config set by the new config in rc.lua, but that must
-- happen for now.)
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
dropdown.add_rules(awful.rules.rules)

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

require "module.tag-toast"
