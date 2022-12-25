local awful = require "awful"

local theme = require "module.theme"
local ui = require "widgets.ui"
local actions = require "actions"

local M = {}

--- @param s screen
function M.build(s)
  local lb = awful.widget.layoutbox {
    screen = s,
    buttons = {
      awful.button({}, Mouse.left_click, actions.next_layout()),
      awful.button({}, Mouse.right_click, actions.previous_layout()),
      awful.button({}, Mouse.scroll_up, actions.next_layout()),
      awful.button({}, Mouse.scroll_up, actions.previous_layout()),
    },
  }

  return ui.button {
    bg = theme.transparent,
    child = ui.margin(theme.spacing(2), theme.spacing(1))(lb),
  }
end

return M
