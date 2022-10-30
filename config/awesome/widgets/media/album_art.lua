local spawn = require "awful.spawn"
local gears = require "gears"
local wibox = require "wibox"
local config_dir = gears.filesystem.get_configuration_dir()
local widget_icon_dir = config_dir .. "widgets/media-info/icons/"

local utils = require "utils"

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

--- @param art_url string?
local function update_album_art(art_url)
  -- Early exit if album art is the same
  if M.current_album_art_url == art_url then
    return
  end
  M.current_album_art_url = art_url

  -- Start by switching to generic "no album" art, download the image, and then
  -- switch to the cached copy.
  set_default()
  if art_url and string.len(art_url) > 5 then
    spawn.easy_async({ "coverart-cache", art_url }, function(stdout)
      if stdout then
        local path = utils.strip(stdout)
        if string.len(path) > 10 then
          set_image(path)
        end
      end
    end)
  end
end

function M.initialize()
  --- @module "module.daemons.playerctl"
  local playerctl = require_module "module.daemons.playerctl"

  return playerctl:on_update(function(player)
    if player then
      update_album_art(player.metadata.art_url)
    else
      update_album_art(nil)
    end
  end)
end

return M
