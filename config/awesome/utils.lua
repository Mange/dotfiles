local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")

-- xproperties are persisted on Awesome restarts, which means we can put a
-- value here on startup and then all restarts will be able to read it out.
awesome.register_xproperty("awesome_restart_check", "boolean")
local restart_detected = awesome.get_xproperty("awesome_restart_check") ~= nil
awesome.set_xproperty("awesome_restart_check", true)

local utils = {
  dpi = xresources.apply_dpi,
}

function utils.run_or_raise(cmd, matchers)
  local c = utils.find_client(matchers)
  if c then
    c:jump_to()
  else
    awful.spawn(cmd, {focus = true})
  end
end

function utils.find_client(matchers)
  for _, c in ipairs(client.get()) do
    if c and awful.rules.match(c, matchers) then
      return c
    end
  end
end

function utils.on_first_start(func)
  if not restart_detected then
    func()
  end
end

function utils.on_restart(func)
  if restart_detected then
    func()
  end
end

function utils.set_wallpaper(s, wallpaper)
    if wallpaper then
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

function utils.reload_wallpaper(s)
  utils.set_wallpaper(s, beautiful.wallpaper)
end

function utils.change_wallpaper(wallpaper) -- luacheck: ignore 131
  beautiful.wallpaper = wallpaper
  for s = 1, screen.count() do
    utils.reload_wallpaper(s)
  end
end

function utils.client_has_tag(c, t)
  for _, tag in ipairs(c:tags()) do
    if tag == t or tag.name == t or tag.index == t then
      return true
    end
  end

  return false
end

return utils
