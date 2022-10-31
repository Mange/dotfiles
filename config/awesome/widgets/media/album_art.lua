local gears = require "gears"
local wibox = require "wibox"
local config_dir = gears.filesystem.get_configuration_dir()
local widget_icon_dir = config_dir .. "widgets/media-info/icons/"

local default_image = widget_icon_dir .. "vinyl.svg"

local M = {}

M.widget = wibox.widget {
  layout = wibox.layout.fixed.vertical,
  {
    widget = wibox.widget.imagebox,
    id = "cover",
    image = default_image,
    resize = true,
  },
}

--- @type string?
M.current_album_art_url = nil

local function set_default()
  M.widget.cover:set_image(default_image)
end
local function set_image(path)
  M.widget.cover:set_image(path)
end

--- @param path string?
local function update_album_art(path)
  if path then
    set_image(path)
  else
    set_default()
  end
end

function M.initialize()
  --- @module "module.daemons.playerctl"
  local playerctl = require_module "module.daemons.playerctl"

  return playerctl:on_update(function(player)
    if player then
      update_album_art(player.metadata.art_path)
    else
      update_album_art(nil)
    end
  end)
end

return M
