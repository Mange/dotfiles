local screen_layout = require "configuration.screens.layout"
local awful = require "awful"
local sharedtags = require "sharedtags"
local icons = require "theme.icons"

local default_layout = awful.layout.suit.tile

local function tagdef(tag_definition)
  -- Find screen it should be on
  local screen = screen_layout.current[tag_definition.screen_type or "main"]
    or screen_layout.current.main

  -- Assign tag to screen
  tag_definition.screen = screen.index

  -- Automatically rotate layout for the screen selection
  tag_definition.layout = screen_layout.layout_rotation(
    tag_definition.layout or default_layout,
    screen
  )

  return tag_definition
end

local tags = sharedtags {
  tagdef {
    name = "System",
    short_name = "SYS",
    icon = icons.system,
    icon_text = "",
  },
  tagdef {
    name = "Coding",
    short_name = "CODE",
    icon = icons.text_editor,
    icon_text = "",
  },
  tagdef {
    name = "Browse",
    short_name = "WWW",
    icon = icons.web_browser,
    icon_text = "",
    screen_type = "reference",
  },
  tagdef {
    name = "Aside",
    short_name = "OTHR",
    icon = icons.terminal,
    icon_text = "",
    screen_type = "comms",
  },
  tagdef {
    name = "Mail",
    short_name = "MAIL",
    icon = icons.mail,
    icon_text = "",
  },
  tagdef {
    name = "Six",
    short_name = "6",
    icon = icons.extensions,
    icon_text = "❻",
  },
  tagdef {
    name = "Seven",
    short_name = "7",
    icon = icons.gear,
    icon_text = "❼",
  },
  tagdef {
    name = "Game",
    short_name = "GAME",
    icon = icons.games,
    icon_text = "",
    layout = awful.layout.suit.max,
  },
  tagdef {
    name = "Media",
    short_name = "PLAY",
    icon = icons.multimedia,
    icon_text = "",
    layout = awful.layout.suit.fair.horizontal,
    screen_type = "comms",
  },
  tagdef {
    name = "Chat",
    short_name = "CHAT",
    icon = icons.social,
    icon_text = "",
    layout = awful.layout.suit.max,
    screen_type = "comms",
  },
}

awful.tag.attached_connect_signal(nil, "property::screen", function(t)
  t.layout = screen_layout.layout_rotation(t.layout, t.screen)
end)

require "configuration.tags.layouts"

return {
  tags = tags,
}
