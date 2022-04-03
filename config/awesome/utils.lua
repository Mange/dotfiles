local awful = require "awful"
local gears = require "gears"
local beautiful = require "beautiful"
local xresources = require "beautiful.xresources"

-- xproperties are persisted on Awesome restarts, which means we can put a
-- value here on startup and then all restarts will be able to read it out.
awesome.register_xproperty("awesome_restart_check", "boolean")
local restart_detected = awesome.get_xproperty "awesome_restart_check" ~= nil
awesome.set_xproperty("awesome_restart_check", true)

-- Check if running inside awmtt (using the test.sh script)
local awmtt_detected = (os.getenv "IN_AWMTT" == "yes")

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

function utils.clamp(min, current, max)
  if current < min then
    return min
  elseif current > max then
    return max
  else
    return current
  end
end

--- Splits a path like "/path/to/file.txt" into "/path/to" and "file.txt".
--- If only a filename is given ("file"), then nil and "file" is returned.
--- @param path string
--- @return string | nil dirname, string basename
function utils.path_split(path)
  local dir, file = string.match(path, "(.-)([^\\/]-)$")
  if dir == "" then
    return nil, file
  else
    return dir, file
  end
end

function utils.run_or_raise(cmd, matchers)
  local c = utils.find_client(matchers)
  if c then
    c:jump_to()
  else
    awful.spawn(cmd, { focus = true })
  end
end

function utils.kill_on_exit(pid)
  if type(pid) == "number" then
    awesome.connect_signal("exit", function()
      -- Negative pid means "Send signal to all processes in this group"
      awesome.kill(-pid, awesome.unix_signal["SIGTERM"])
    end)
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

function utils.is_test()
  return awmtt_detected or _G.is_test == true
end

-- Uses gears.debug.dump_return to log a complex value to a log file.
--- @param log_name string The name of the log
--- @param data any value to log
--- @param tag string The name of the value
--- @param depth? integer Depth of recursion
function utils.log(log_name, data, tag, depth)
  local filename = gears.filesystem.get_xdg_cache_home()
    .. "awesome/"
    .. log_name
    .. ".log"
  local f = assert(io.open(filename, "a"))
  if type(data) == "string" then
    f:write(data)
  else
    f:write(gears.debug.dump_return(data, tag, depth))
  end
  f:write "\n"
  f:close()
end

function utils.wallpaper_path(name)
  return gears.filesystem.get_xdg_data_home() .. "wallpapers/" .. name
end

function utils.reload_wallpaper(s)
  gears.wallpaper.maximized(
    s.wallpaper_override or beautiful.wallpaper,
    s,
    false
  )
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
  local f = awful.placement.scale
    + awful.placement.no_offscreen
    + awful.placement.centered

  return function(c)
    f(c, { to_percent = scale })
  end
end

function utils.placement_downright(scale)
  local f = awful.placement.scale
    + awful.placement.no_offscreen
    + awful.placement.bottom_right

  return function(c)
    f(c, { to_percent = scale })
  end
end

return utils
