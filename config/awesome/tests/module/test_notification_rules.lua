local luaunit = require "luaunit"
local gears = require "gears"
local notification_rules = require "module.notification_rules"

local test_class = {}

--- @param overrides table
local function build_notification(overrides)
  return gears.table.join({
    title = "Some title",
    app_name = "App name",
    urgency = "normal",
    appname = "App name",
    message = "Hello world",
    timeout = 0,
  }, overrides)
end

function test_class:test_handle_spotify()
  local args = build_notification {
    app_name = "Spotify",
    appname = "Spotify",
    urgency = "normal",
  }

  luaunit.assert_true(notification_rules.handle(args))

  -- Spotify notifications get low urgency and a short timeout
  luaunit.assert_equals(args.urgency, "low")
  luaunit.assert_equals(args.timeout, 2)
end

function test_class:test_handle_brave_ads()
  local args = build_notification {
    app_name = "Brave",
    appname = "Brave",
    urgency = "critical",
    title = "Earn while you sleep with AAX",
    message = " \n\nUp to 60% APY on BTC, ETH, USDT &amp; USDC savings",
  }

  -- Return false to reject the notification
  luaunit.assert_false(notification_rules.handle(args))

  -- In case notification wasn't rejected on callsite, also make sure it won't
  -- show up in an annoying way…
  luaunit.assert_equals(args.urgency, "low")
  luaunit.assert_equals(args.timeout, 1)
  luaunit.assert_equals(args.title, "Adblock")
  luaunit.assert_equals(args.message, "")
end

function test_class:test_handle_brave_calendar_notifications()
  local args = build_notification {
    app_name = "Brave",
    appname = "Brave",
    title = "Example Meeting",
    message = "calendar.google.com\n\n14:00 - 16:00\nSome Address 1337",
    -- Not actually what is set, but we want to make sure it's overridden *if*
    -- it is set this way some day.
    urgency = "normal",
    timeout = 1,
  }

  luaunit.assert_true(notification_rules.handle(args))

  -- Important and don't time it out
  luaunit.assert_equals(args.urgency, "critical")
  luaunit.assert_equals(args.timeout, 0)
end

return test_class
