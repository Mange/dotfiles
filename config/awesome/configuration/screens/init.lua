local awful = require "awful"
local screen_layout = require "configuration.screens.layout"

awful.screen.connect_for_each_screen(function()
  screen_layout.refresh()
end)
