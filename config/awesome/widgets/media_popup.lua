local awful = require "awful"
local wibox = require "wibox"
local ui = require "widgets.ui"

--- @module "module.theme"
local theme = require_module "module.theme"
--- @module "widgets.media.album_art"
local album_art = require_module "widgets.media.album_art"
--- @module "widgets.media.title"
local title = require_module "widgets.media.title"
--- @module "widgets.media.artist"
local artist = require_module "widgets.media.artist"
--- @module "widgets.media.player_info"
local player_info = require_module "widgets.media.player_info"

local M = {}

function M.initialize()
  return function() end
end

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

  popup.widget = awful.popup {
    screen = s,
    ontop = true,
    preferred_anchors = { "front", "middle" },
    preferred_positions = { "bottom" },
    visible = is_test_mode(),
    offset = {
      y = theme.spacing(2),
    },
    widget = ui.panel {
      bg = theme.surface0,
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
        ui.margin(0, 0, 0, theme.spacing(2))(ui.justify_between_col({
          layout = wibox.layout.fixed.vertical,
          spacing = theme.spacing(1),
          title.widget,
          artist.widget,
        }, ui.align_right(player_info.widget))),
      },
    },
  }

  popup.show_at = function(self, anchor)
    self.widget:move_next_to(find_panel_geometry_from_hover(anchor))
    self.widget.visible = true
  end

  popup.hide = function(self)
    self.widget.visible = false
  end

  return popup
end

return M
