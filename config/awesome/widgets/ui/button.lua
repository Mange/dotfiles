local wibox = require "wibox"

local theme = require_module "module.theme"
--- @module "widgets.ui.effects"
local ui_effects = require_module "widgets.ui.effects"

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
  local opts = options or {}
  local bg = opts.bg or theme.crust
  local bg_hover = opts.bg_hover or theme.surface0
  local bg_click = opts.bg_click or theme.surface1

  local container = wibox.widget {
    widget = wibox.container.background,
    bg = bg,
    options.child,
  }

  ui_effects.use_clickable(container, {
    bg = bg,
    bg_hover = bg_hover,
    bg_click = bg_click,
    on_left_click = options.on_left_click,
    on_mouse_enter = options.on_mouse_enter,
    on_mouse_leave = options.on_mouse_leave,
  })

  return container
end

return M
