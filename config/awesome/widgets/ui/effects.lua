local ui_constants = require "widgets.ui.constants"

local M = {}

function M.initialize()
  return function() end
end

--- @class UseClickableOptions
--- @field bg string | nil
--- @field bg_hover string | nil
--- @field bg_click string | nil
--- @field bg_widget widget | nil
--- @field on_left_click function(widget) | nil
--- @field on_right_click function(widget) | nil
--- @field on_mouse_enter function(widget) | nil
--- @field on_mouse_leave function(widget) | nil

--- @param widget widget
--- @param options UseClickableOptions | nil
--- @return function() cleanup function
function M.use_clickable(widget, options)
  local opts = options or {}
  local bg_widget = opts.bg_widget or widget

  local on_left_click = opts.on_left_click or function() end
  local on_right_click = opts.on_right_click or function() end
  local on_mouse_enter = opts.on_mouse_enter or function() end
  local on_mouse_leave = opts.on_mouse_leave or function() end

  local hovering = false
  local button_down = false
  -- Original bg could be nil, so use extra sentinel to tell if the nil is
  -- "don't change" or "set to nil".
  local original_bg_set = false
  local original_bg = bg_widget.bg

  local function update_bg()
    if not original_bg_set then
      original_bg_set = true
      original_bg = bg_widget.bg
    end

    if button_down and opts.bg_click then
      bg_widget.bg = opts.bg_click
    elseif hovering and opts.bg_hover then
      bg_widget.bg = opts.bg_hover
    elseif opts.bg then
      bg_widget.bg = opts.bg
    elseif original_bg_set then
      bg_widget.bg = original_bg
      original_bg = nil
      original_bg_set = false
    end
  end

  -- Mouse cursor cannot be set on individual widgets; only on the wibox that
  -- the widgets are contained in. Consider wibox like a "window" here.
  -- So on hovering, change the cursor of the containing wibox and then restore
  -- it again afterwards.
  local pre_hover_wibox = nil
  local pre_hover_cursor = nil

  local function mouse_enter()
    hovering = true
    local current = mouse.current_wibox
    if current then
      pre_hover_wibox = current
      pre_hover_cursor = current.cursor
      current.cursor = "hand2" -- pointing finger
    end
    update_bg()
    on_mouse_enter(widget)
  end

  local function mouse_leave()
    hovering = false
    if pre_hover_wibox then
      pre_hover_wibox.cursor = pre_hover_cursor
      pre_hover_wibox = nil
      pre_hover_cursor = nil
    end
    update_bg()
    on_mouse_leave(widget)
  end

  local function button_press(_, _, _, mbutton)
    button_down = true
    update_bg()
    if mbutton == ui_constants.left_click then
      on_left_click(widget)
    elseif mbutton == ui_constants.right_click then
      on_right_click(widget)
    end
  end

  local function button_release()
    button_down = false
    update_bg()
  end

  widget:connect_signal("mouse::enter", mouse_enter)
  widget:connect_signal("mouse::leave", mouse_leave)
  widget:connect_signal("button::press", button_press)
  widget:connect_signal("button::release", button_release)

  return function()
    if widget then
      widget:disconnect_signal("mouse::enter", mouse_enter)
      widget:disconnect_signal("mouse::leave", mouse_leave)
      widget:disconnect_signal("button::press", button_press)
      widget:disconnect_signal("button::release", button_release)
    end
  end
end

return M