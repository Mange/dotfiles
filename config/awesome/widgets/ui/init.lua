local wibox = require "wibox"
local gears = require "gears"

local theme = require "module.theme"

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

  return function(...)
    return {
      widget = wibox.container.margin,
      top = t,
      right = r,
      bottom = b,
      left = l,
      ...,
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

--- @class VerticalOptions
--- @field children widget[]
--- @field spacing number | nil
--- @field bg string | nil

--- @param options VerticalOptions
--- @return widget
function M.vertical(options)
  return {
    layout = wibox.layout.fixed.vertical,
    spacing = options.spacing or theme.spacing(1),
    bg = options.bg or theme.transparent,
    table.unpack(options.children),
  }
end

function M.justify_between_col(top, bottom)
  return {
    layout = wibox.layout.align.vertical,
    expand = "none",
    top,
    nil,
    bottom,
  }
end

function M.align_right(widget)
  return {
    layout = wibox.layout.align.horizontal,
    expand = "none",
    nil,
    nil,
    widget,
  }
end

--- @class PanelOptions
--- @field children widget[]
--- @field bg string | nil
--- @field layout "horizontal" | "vertical" | nil
--- @field margin function(widget): widget | nil

--- @param options PanelOptions
--- @return widget
function M.panel(options)
  local child
  if options.layout == "horizontal" then
    child = M.horizontal { children = options.children }
  elseif options.layout == "vertical" then
    child = M.vertical { children = options.children }
  else
    -- Deprecated. Require a layout to be specified later!
    child = M.horizontal { children = options.children }
  end

  local margin = options.margin or M.margin(2, 4)

  return {
    widget = wibox.container.background,
    bg = options.bg or theme.background,
    shape = function(cr, w, h)
      gears.shape.rounded_rect(cr, w, h, dpi(7))
    end,
    margin(child),
  }
end

local button_module = require "widgets.ui.button"
M.button = button_module.button

return M
