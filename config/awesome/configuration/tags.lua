local awful = require "awful"
local bling = require "vendor.bling"

local icons = require "theme.icons"
local default_layout = bling.layout.centered

--- @class TagConfig
--- @field name string
--- @field short_name string
--- @field icon string
--- @field layout unknown
--- @field screen_type ScreenType | nil

return {
  {
    name = "System",
    short_name = "SYS",
    icon = icons.device_desktop,
    layout = default_layout,
  },
  {
    name = "Coding",
    short_name = "CODE",
    icon = icons.code,
    layout = awful.layout.suit.tile,
  },
  {
    name = "Browse",
    short_name = "WWW",
    icon = icons.world,
    layout = default_layout,
    screen_type = "reference",
  },
  {
    name = "Aside",
    short_name = "OTHR",
    icon = icons.terminal_2,
    screen_type = "comms",
    layout = awful.layout.fair,
  },
  {
    name = "Notes",
    short_name = "NOTE",
    icon = icons.notebook,
    layout = default_layout,
  },
  {
    name = "Six",
    short_name = "6",
    icon = icons.square_6,
    layout = default_layout,
  },
  {
    name = "Seven",
    short_name = "7",
    icon = icons.square_7,
    layout = default_layout,
  },
  {
    name = "Game",
    short_name = "GAME",
    icon = icons.brand_steam,
    layout = awful.layout.suit.max,
  },
  {
    name = "Media",
    short_name = "PLAY",
    icon = icons.playlist,
    layout = awful.layout.suit.fair.horizontal,
    screen_type = "comms",
  },
  {
    name = "Chat",
    short_name = "CHAT",
    icon = icons.brand_telegram,
    layout = awful.layout.suit.max,
    screen_type = "comms",
  },
}
