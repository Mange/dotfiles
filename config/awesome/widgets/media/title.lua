local wibox = require "wibox"
local theme = require "module.theme"
local playerctl = require "module.daemons.playerctl"

local M = {}

M.widget = wibox.widget {
  widget = wibox.widget.textbox,
  font = theme.font_bold,
  id = "title",
  text = "No media",
  visible = false,
}

local cleanup = playerctl:on_update(function(player)
  if player then
    M.widget:set_text(player.metadata.title or "No Media")
    M.widget.visible = true
  else
    M.widget:set_text "No Media"
    M.widget.visible = false
  end
end)

on_module_cleanup(M, cleanup)
return M
