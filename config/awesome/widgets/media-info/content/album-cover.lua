local gears = require "gears"
local wibox = require "wibox"
local config_dir = gears.filesystem.get_configuration_dir()
local widget_icon_dir = config_dir .. "widgets/media-info/icons/"

local default_image = widget_icon_dir .. "vinyl.svg"

local album_cover = wibox.widget {
  layout = wibox.layout.fixed.vertical,
  {
    id = "cover",
    image = default_image,
    resize = true,
    clip_shape = gears.shape.rounded_rect,
    widget = wibox.widget.imagebox,
  },
}

return {
  widget = album_cover,

  set_default = function()
    album_cover.cover:set_image(default_image)
  end,

  set_image = function(path)
    album_cover.cover:set_image(path)
  end,
}
