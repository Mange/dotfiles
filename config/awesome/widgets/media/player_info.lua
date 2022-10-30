local wibox = require "wibox"

local utils = require "utils"
--- @module "module.theme"
local theme = require_module "module.theme"

local M = {}

M.spotify_logo = wibox.widget {
  widget = wibox.widget.imagebox,
  image = theme.icon.spotify,
  resize = true,
  visible = false,
}

M.player_name = wibox.widget {
  widget = wibox.widget.textbox,
  font = theme.font_size(9),
  id = "name",
  text = "No player",
}

M.widget = wibox.widget {
  layout = wibox.layout.fixed.horizontal,
  visible = false,
  spacing = theme.spacing(2),
  {
    widget = wibox.container.constraint,
    width = theme.spacing(4),
    height = theme.spacing(4),
    M.spotify_logo,
  },
  M.player_name,
}

function M.initialize()
  --- @module "module.daemons.playerctl"
  local playerctl = require_module "module.daemons.playerctl"

  return playerctl:on_update(function(player)
    if player then
      M.player_name:set_text(utils.capitalize(player.name or "No player"))
      M.spotify_logo.visible = player.name == "spotify"
      M.widget.visible = true
    else
      M.player_name:set_text "No player"
      M.spotify_logo.visible = false
      M.widget.visible = false
    end
  end)
end

return M
