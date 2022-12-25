local wibox = require "wibox"

local theme = require "module.theme"

local M = {}

--- @param s screen
function M.build(s)
  return wibox.widget {
    widget = wibox.widget.systray,
    screen = s,
    base_size = theme.spacing(4),
  }
end

return M
