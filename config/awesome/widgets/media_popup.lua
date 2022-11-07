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

local M = {
  cleanups_functions = {},
}

local function cleanup_on_reload(func)
  M.cleanups_functions[#M.cleanups_functions + 1] = func
end

function M.initialize()
  M.cleanups_functions = {}

  return function()
    for _, cleanup in ipairs(M.cleanups_functions) do
      cleanup()
    end
  end
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

  --- @module "module.daemons.playerctl"
  local playerctl = require_module "module.daemons.playerctl"

  --- @param player Player | nil
  local function update(player)
    if player and player.metadata.art_path then
      content.bgimage = player.metadata.art_path
    else
      content.bgimage = nil
    end
  end

  update(playerctl:current())
  cleanup_on_reload(playerctl:on_update(update))

  return popup
end

return M
