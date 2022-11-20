local awful = require "awful"
local beautiful = require "beautiful"
local gears = require "gears"

local keys = initialize_module(require "module.keys")
local utils = require "utils"
local tags = require("module.tags").tags

local clientbuttons = gears.table.join(
  awful.button({}, Mouse.left_click, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
  end),
  awful.button({ Key.super }, Mouse.left_click, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
    awful.mouse.client.move(c)
  end),
  awful.button({ Key.super }, Mouse.right_click, function(c)
    c:emit_signal("request::activate", "mouse_click", { raise = true })
    awful.mouse.client.resize(c)
  end)
)

return {
  -- All clients will match this rule.
  {
    rule = {},
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      raise = true,
      size_hints_honor = false,
      keys = keys.clients,
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
        -- Pop behaves super crazy; better to start out floating always and then
        -- manually fixing it when it's placed where I want it.
        "Pop",
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

  {
    rule = { class = "Workrave" },
    properties = {
      titlebars_enabled = false,
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
