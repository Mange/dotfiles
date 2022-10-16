local wibox = require "wibox"
local gears = require "gears"

local theme = require_module "module.theme"

local M = {}

--- Returns a function that wraps a component inside a margin container. The
--- margin options is the same as the `margin` CSS property.
---
--- **Example:**
---
---     ui.margin(10, 5) {
---       widget = awful.widget.textbox,
---       text = "Hello"
---     }
---
---     ui.margin(10, 5)(
---       ui.placeholder("#ff0000", "RED")
---     )
---
--- @overload fun(margin: number): fun(component: widget): widget
--- @overload fun(vertical: number, horizontal: number): fun(component: widget): widget
--- @overload fun(top: number, horizontal: number, bottom: number): fun(component: widget): widget
function M.margin(top, right, bottom, left)
  local t = top -- top or margin
  local r = right or top -- right or horizontal or margin
  local b = bottom or top -- bottom or vertical or margin
  local l = left or right or top -- left or horizontal or margin

  return function(child)
    return {
      widget = wibox.container.margin,
      top = t,
      right = r,
      bottom = b,
      left = l,
      child,
    }
  end
end

--- @param color string
--- @param text string | nil
function M.placeholder(color, text)
  local text_widget = nil

  if text then
    text_widget = {
      widget = wibox.widget.textbox,
      text = text,
    }
  end

  return {
    widget = wibox.container.background,
    bg = color,
    text_widget,
  }
end

--- @class HorizontalOptions
--- @field children widget[]
--- @field spacing number | nil
--- @field bg string | nil

--- @param options HorizontalOptions
--- @return widget
function M.horizontal(options)
  return {
    layout = wibox.layout.fixed.horizontal,
    spacing = options.spacing or theme.spacing(1),
    bg = options.bg or theme.transparent,
    table.unpack(options.children),
  }
end

--- @class PanelOptions
--- @field children widget[]
--- @field spacing number | nil
--- @field bg string | nil

--- @param options PanelOptions
--- @return widget
function M.panel(options)
  return {
    widget = wibox.container.background,
    bg = options.bg or theme.background,
    shape = function(cr, w, h)
      gears.shape.rounded_rect(cr, w, h, dpi(7))
    end,
    M.margin(2, 4)(M.horizontal {
      children = options.children,
    }),
  }
end

--- @class ButtonOptions
--- @field text string
--- @field on_click function

--- @param options ButtonOptions
--- @return widget
function M.button(options) end

return M
