local utils = require "utils"

local function find_icon(app_name, callback)
  awful.spawn.easy_async(
    { "find-icon-file", app_name },
    function(stdout, stderr, exitreason, exitcode)
      if exitcode == 0 then
        local path = utils.strip(stdout)
        if path ~= "" then
          callback(path)
          return
        end
      end

      callback(nil)
    end
  )
end

local function load_image_file(path)
  local cairo = require("lgi").cairo
  local surface = gears.surface(path)
  local image = cairo.ImageSurface.create(
    cairo.Format.ARGB32,
    surface:get_width(),
    surface:get_height()
  )
  local context = cairo.Context(image)
  context:set_source_surface(surface, 0, 0)
  context:paint()
  return image._native
end

local function fix_missing_icon(c)
  if c and c.valid and not c.icon and c.class then
    local candidates = utils.uniq {
      c.class,
      string.lower(c.class),
    }

    utils.async_foreach(candidates, function(_, candidate, continue)
      find_icon(candidate, function(path)
        if path ~= nil then
          c.icon = load_image_file(path)
        else
          continue()
        end
      end)
    end)
  end
end

return fix_missing_icon
