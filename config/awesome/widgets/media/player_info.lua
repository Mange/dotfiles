local wibox = require "wibox"

local utils = require "utils"
local theme = require "module.theme"
local playerctl = require "module.daemons.playerctl"

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

local cleanup = playerctl:on_update(function(player)
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
on_module_cleanup(M, cleanup)

return M
