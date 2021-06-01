local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")

-- xproperties are persisted on Awesome restarts, which means we can put a
-- value here on startup and then all restarts will be able to read it out.
awesome.register_xproperty("awesome_restart_check", "boolean")
local restart_detected = awesome.get_xproperty("awesome_restart_check") ~= nil
awesome.set_xproperty("awesome_restart_check", true)

-- Check if running inside awmtt (using the test.sh script)
local awmtt_detected = (os.getenv("IN_AWMTT") == "yes")

local utils = {
  dpi = xresources.apply_dpi,
}

function utils.strip(str)
  if str ~= nil then
    return (string.gsub(str, "^%s*(.-)%s*$", "%1"))
  else
    return ""
  end
end

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
  if not restart_detected and not awmtt_detected then
    func()
  end
end

function utils.wallpaper_path(name)
  return gears.filesystem.get_xdg_data_home() .. "wallpapers/" .. name
end

function utils.reload_wallpaper(s)
  gears.wallpaper.maximized(s.wallpaper_override or beautiful.wallpaper, s, false)
end

function utils.reload_wallpapers()
  for s in screen do
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

function utils.placement_centered(scale)
  local f =
    awful.placement.scale +
    awful.placement.no_offscreen +
    awful.placement.centered

  return function(c)
    f(c, {to_percent = scale})
  end
end

function utils.placement_downright(scale)
  local f =
    awful.placement.scale +
    awful.placement.no_offscreen +
    awful.placement.bottom_right

  return function(c)
    f(c, {to_percent = scale})
  end
end

return utils
