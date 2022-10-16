local awful = require "awful"
local gears = require "gears"
local xresources = require "beautiful.xresources"

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

function utils.uniq(table)
  local seen = {}
  local new = {}
  for _, item in ipairs(table) do
    if not seen[item] then
      seen[item] = true
      new[#new + 1] = item
    end
  end

  return new
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

--- @generic T
--- @param list T[]
--- @param callback fun(index:number,item:T,continue:fun())
function utils.async_foreach(list, callback)
  local items = gears.table.clone(list)
  local index = 0
  local combinator = function(myself)
    index = index + 1
    if #items >= index then
      callback(index, items[index], function()
        myself(myself)
      end)
    end
  end
  combinator(combinator)
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

--- @deprecated Use global `is_test_mode()` instead
function utils.is_test()
  return is_test_mode()
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

function utils.first_wallpaper_path(names)
  for _, name in ipairs(names) do
    local path = utils.wallpaper_path(name)
    if gears.filesystem.file_readable(path) then
      return path
    end
  end

  return utils.wallpaper_path "landscape.jpg"
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

function utils.client_index(c)
  local index = 0

  local filter = function(clnt)
    return not (
        c.hidden
        or c.type == "splash"
        or c.type == "dock"
        or c.type == "desktop"
      ) and awful.widget.tasklist.filter.currenttags(clnt, c.screen)
  end

  for _, other in ipairs(client.get()) do
    if filter(other) then
      index = index + 1
    end

    if other == c then
      return index
    end
  end

  -- Client isn't visible on the screen, assume placed last. Could happen if
  -- invisible, for example…
  return index + 1
end

function utils.is_master(c)
  local index = utils.client_index(c)
  return index <= c.screen.selected_tag.master_count
end

return utils
