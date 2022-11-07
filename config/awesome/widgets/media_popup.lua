local awful = require "awful"
local wibox = require "wibox"
local ui = require "widgets.ui"

local theme = require "module.theme"
local album_art = require "widgets.media.album_art"
local title = require "widgets.media.title"
local artist = require "widgets.media.artist"
local player_info = require "widgets.media.player_info"
local playerctl = require "module.daemons.playerctl"

local M = {}

local function find_panel_geometry_from_hover(panel)
  -- If hovering a widget that is a child of the panel, then the panel will be
  -- part of the hierarchy.
  local widgets, geometries = mouse.get_current_widgets()
  for i, widget in ipairs(widgets) do
    if widget == panel then
      return geometries[i]
    end
  end

  -- Not found? Then return the last geometry (i.e. the top-most widget that is hovered…)
  return geometries[#geometries]
end

function M.new(s)
  local popup = {}

  local content = wibox.widget {
    widget = wibox.container.background,
    ui.panel {
      bg = theme.opacity(theme.surface0, "bb"),
      margin = ui.margin(theme.spacing(2)),
      --
      -- The layout of the children here is pretty complex. It's oulined below in order to help a bit:
      --
      -- ┌───────────────────────────────────────────────────────────────────────────────────────┐
      -- │                                                                                       │
      -- │ ┌───────────────────────────────────────┐ ┌─────────────────────────────────────────┐ │
      -- │ │                                       │ │                                         │ │
      -- │ │                                       │ │  Title                                  │ │
      -- │ │                                       │ │                                         │ │
      -- │ │                                       │ │  Artist                                 │ │
      -- │ │                                       │ │                                         │ │
      -- │ │                                       │ ├─────────────────────────────────────────┤ │
      -- │ │        Album art                      │ │                                         │ │
      -- │ │                                       │ │              Empty                      │ │
      -- │ │                                       │ │                                         │ │
      -- │ │                                       │ ├──────┬────────────────────┬─────────────┤ │
      -- │ │                                       │ │      │                    │             │ │
      -- │ │                                       │ │ Empty│   Empty            │ Player info │ │
      -- │ │                                       │ │      │                    │             │ │
      -- │ └───────────────────────────────────────┘ └──────┴────────────────────┴─────────────┘ │
      -- │                                                                                       │
      -- └───────────────────────────────────────────────────────────────────────────────────────┘
      --
      children = {
        layout = wibox.layout.align.horizontal,
        {
          layout = wibox.container.constraint,
          strategy = "exact",
          height = theme.spacing(22),
          width = theme.spacing(22),
          album_art.widget,
        },
        ui.margin(0, 0, 0, theme.spacing(2)) {
          layout = wibox.container.constraint,
          strategy = "min",
          width = theme.spacing(62),
          ui.justify_between_col({
            layout = wibox.layout.fixed.vertical,
            spacing = theme.spacing(1),
            title.widget,
            artist.widget,
          }, ui.align_right(player_info.widget)),
        },
      },
    },
  }

  popup.widget = awful.popup {
    screen = s,
    ontop = true,
    preferred_anchors = { "front", "middle" },
    preferred_positions = { "bottom" },
    visible = false,
    offset = {
      y = theme.spacing(2),
    },
    widget = content,
  }

  popup.show_at = function(self, anchor)
    self.widget:move_next_to(find_panel_geometry_from_hover(anchor))
    self.widget.visible = true
  end

  popup.hide = function(self)
    self.widget.visible = false
  end

  --- @param player Player | nil
  local function update(player)
    if player and player.metadata.art_path then
      content.bgimage = player.metadata.art_path
    else
      content.bgimage = nil
    end
  end

  update(playerctl:current())
  local cleanup = playerctl:on_update(update)
  on_module_cleanup(M, cleanup)

  return popup
end

return M
