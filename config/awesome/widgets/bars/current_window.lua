local awful = require "awful"
local wibox = require "wibox"
local ui = require "widgets.ui"
local theme = require "module.theme"

local M = {}

--- @param s screen
function M.build(s)
  return awful.widget.tasklist {
    screen = s,
    filter = awful.widget.tasklist.filter.focused,
    buttons = {},
    -- style = {},
    layout = {
      layout = wibox.layout.flex.horizontal,
    },
    widget_template = {
      widget = wibox.container.place,
      {
        id = "background_role",
        widget = wibox.container.background,
        ui.margin(theme.spacing(1), theme.spacing(2)) {
          layout = wibox.layout.fixed.horizontal,
          ui.margin(theme.spacing(2)) {
            widget = awful.widget.clienticon,
          },
          {
            id = "text_role",
            widget = wibox.widget.textbox,
          },
        },
      },
    },
  }
end

return M
