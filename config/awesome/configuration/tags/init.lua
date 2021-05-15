local screen_layout = require("configuration.screens.layout")
local awful = require("awful")
local sharedtags = require("sharedtags")

local tags = sharedtags({
    {
      name = "System",
      icon_text = "",
      layout = awful.layout.suit.tile,
      screen = screen_layout.current.main.index,
    },
    {
      name = "Code",
      icon_text = "",
      layout = awful.layout.suit.tile,
      screen = screen_layout.current.main.index,
    },
    {
      name = "Browse",
      icon_text = "",
      layout = awful.layout.suit.tile,
      screen = screen_layout.current.reference.index,
    },
    {
      name = "Aside",
      icon_text = "",
      layout = awful.layout.suit.tile,
      screen = screen_layout.current.comms.index,
    },
    {
      name = "Mail",
      icon_text = "",
      layout = awful.layout.suit.tile,
      screen = screen_layout.current.main.index,
    },
    {
      name = "6",
      icon_text = nil,
      layout = awful.layout.suit.tile,
      screen = screen_layout.current.main.index,
    },
    {
      name = "7",
      icon_text = nil,
      layout = awful.layout.suit.tile,
      screen = screen_layout.current.main.index,
    },
    {
      name = "Game",
      icon_text = "",
      layout = awful.layout.suit.max,
      screen = screen_layout.current.main.index,
    },
    {
      name = "Media",
      icon_text = "",
      layout = awful.layout.suit.fair.horizontal,
      screen = screen_layout.current.comms.index,
    },
    {
      name = "Chat",
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
