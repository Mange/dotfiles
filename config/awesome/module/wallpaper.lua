--
-- Set up wallpaper on each screen and reset wallpaper when screen geometry changes.
--

local awful = require "awful"
local gears = require "gears"
local beautiful = require "beautiful"

local function reload_wallpaper(s)
  gears.wallpaper.maximized(s.wallpaper_override or beautiful.wallpaper, s)
end

return {
  --- @type ModuleInitializerFunction
  initialize = function()
    -- When a screen is added, and for all currently added screens
    awful.screen.connect_for_each_screen(reload_wallpaper)
    -- When a screen changes geometry
    screen.connect_signal("property::geometry", reload_wallpaper)

    return function()
      screen.disconnect_signal("property::geometry", reload_wallpaper)
      awful.screen.disconnect_for_each_screen(reload_wallpaper)
    end
  end,
}
