local utils = require "utils"
local screen_layout = require "configuration.screens.layout"

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", utils.reload_wallpaper)

awful.screen.connect_for_each_screen(function(s)
  screen_layout.refresh()
  utils.reload_wallpapers()
end)
