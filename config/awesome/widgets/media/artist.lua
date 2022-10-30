local wibox = require "wibox"

local M = {}

M.widget = wibox.widget {
  widget = wibox.widget.textbox,
  id = "artist",
  text = "No artist",
  visible = false,
}

function M.initialize()
  --- @module "module.daemons.playerctl"
  local playerctl = require_module "module.daemons.playerctl"

  return playerctl:on_update(function(player)
    if player then
      M.widget:set_text(
        player.metadata.artist or player.metadata.album_artist or "No artist"
      )
      M.widget.visible = true
    else
      M.widget:set_text "No artist"
      M.widget.visible = false
    end
  end)
end

return M
