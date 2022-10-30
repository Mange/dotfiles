local wibox = require "wibox"

--- @module "module.theme"
local theme = require_module "module.theme"

local M = {}

M.widget = wibox.widget {
  widget = wibox.widget.textbox,
  font = theme.font_bold,
  id = "title",
  text = "No media",
  visible = false,
}

function M.initialize()
  --- @module "module.daemons.playerctl"
  local playerctl = require_module "module.daemons.playerctl"

  return playerctl:on_update(function(player)
    if player then
      M.widget:set_text(player.metadata.title or "No Media")
      M.widget.visible = true
    else
      M.widget:set_text "No Media"
      M.widget.visible = false
    end
  end)
end

return M
