local wibox = require "wibox"

local theme = require_module "module.theme"
local ui_constants = require "widgets.ui.constants"

local M = {}

--- @class ButtonOptions
--- @field child widget
--- @field bg string | nil
--- @field bg_hover string | nil
--- @field bg_click string | nil
--- @field on_left_click function | nil
--- @field on_mouse_enter function | nil
--- @field on_mouse_leave function | nil

--- @param options ButtonOptions
--- @return widget
function M.button(options)
  local bg = options.bg or theme.crust
  local bg_hover = options.bg_hover or theme.surface0
  local bg_click = options.bg_click or theme.surface1

  local on_left_click = options.on_left_click or function() end
  local on_mouse_enter = options.on_mouse_enter or function() end
  local on_mouse_leave = options.on_mouse_leave or function() end

  local container = wibox.widget {
    widget = wibox.container.background,
    bg = bg,
    options.child,
  }

  local hovering = false
  local button_down = false
  local function update_bg()
    if button_down then
      container.bg = bg_click
    elseif hovering then
      container.bg = bg_hover
    else
      container.bg = bg
    end
  end

  -- Mouse cursor cannot be set on individual widgets; only on the wibox that
  -- the widgets are contained in. Consider wibox like a "window" here.
  -- So on hovering, change the cursor of the containing wibox and then restore
  -- it again afterwards.
  local pre_hover_wibox = nil
  local pre_hover_cursor = nil

  container:connect_signal("mouse::enter", function()
    hovering = true
    local current = mouse.current_wibox
    if current then
      pre_hover_wibox = current
      pre_hover_cursor = current.cursor
      current.cursor = "hand2" -- pointing finger
    end
    update_bg()
    on_mouse_enter()
  end)

  container:connect_signal("mouse::leave", function()
    hovering = false
    if pre_hover_wibox then
      pre_hover_wibox.cursor = pre_hover_cursor
      pre_hover_wibox = nil
      pre_hover_cursor = nil
    end
    update_bg()
    on_mouse_leave()
  end)

  container:connect_signal("button::press", function(_, _, _, mbutton)
    button_down = true
    update_bg()
    if mbutton == ui_constants.left_click then
      container.bg = bg_click
      on_left_click()
    end
  end)

  container:connect_signal("button::release", function()
    button_down = false
    update_bg()
  end)

  return container
end

return M
