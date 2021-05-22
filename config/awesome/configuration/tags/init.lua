local screen_layout = require("configuration.screens.layout")
local awful = require("awful")
local sharedtags = require("sharedtags")
local icons = require("theme.icons")

local tags = sharedtags({
    {
      name = "System",
      short_name = "SYS",
      icon = icons.sandbox,
      icon_text = "",
      layout = awful.layout.suit.tile,
      screen = screen_layout.current.main.index,
    },
    {
      name = "Coding",
      short_name = "CODE",
      icon = icons.text_editor,
      icon_text = "",
      layout = awful.layout.suit.tile,
      screen = screen_layout.current.main.index,
    },
    {
      name = "Browse",
      short_name = "WWW",
      icon = icons.web_browser,
      icon_text = "",
      layout = awful.layout.suit.tile,
      screen = screen_layout.current.reference.index,
    },
    {
      name = "Aside",
      short_name = "OTHR",
      icon = icons.terminal,
      icon_text = "",
      layout = awful.layout.suit.tile,
      screen = screen_layout.current.comms.index,
    },
    {
      name = "Mail",
      short_name = "MAIL",
      -- icon = icons.sandbox,
      icon_text = "",
      layout = awful.layout.suit.tile,
      screen = screen_layout.current.main.index,
    },
    {
      name = "6",
      short_name = "SIX",
      -- icon = icons.sandbox,
      icon_text = "❻",
      layout = awful.layout.suit.tile,
      screen = screen_layout.current.main.index,
    },
    {
      name = "7",
      short_name = "SEVN",
      -- icon = icons.sandbox,
      icon_text = "❼",
      layout = awful.layout.suit.tile,
      screen = screen_layout.current.main.index,
    },
    {
      name = "Game",
      short_name = "GAME",
      icon = icons.games,
      icon_text = "",
      layout = awful.layout.suit.max,
      screen = screen_layout.current.main.index,
    },
    {
      name = "Media",
      short_name = "PLAY",
      icon = icons.multimedia,
      icon_text = "",
      layout = awful.layout.suit.fair.horizontal,
      screen = screen_layout.current.comms.index,
    },
    {
      name = "Chat",
      short_name = "CHAT",
      icon = icons.social,
      icon_text = "",
      layout = awful.layout.suit.max,
      screen = screen_layout.current.comms.index,
    },
})

awful.tag.attached_connect_signal(nil, "property::screen", function(t)
    screen_layout.tag_layout_rotation(t)
end)

require("configuration.tags.layouts")

return {
  tags = tags
}
