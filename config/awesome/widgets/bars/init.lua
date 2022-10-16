local wibox = require "wibox"
local awful = require "awful"

--- @module "module.theme"
local theme = require_module "module.theme"
local ui = require "widgets.ui"

local control_bar = require_module "widgets.bars.control"
local media_bar = require_module "widgets.bars.media"
local window_bar = require_module "widgets.bars.window"
local status_bar = require_module "widgets.bars.status"
local state_bar = require_module "widgets.bars.state"

local M = {}

function M.initialize()
  return function()
    cleanup_module "module.theme"
    cleanup_module "widgets.bars.control"
    cleanup_module "widgets.bars.media"
    cleanup_module "widgets.bars.window"
    cleanup_module "widgets.bars.status"
    cleanup_module "widgets.bars.state"
  end
end

-- Layout of the bar:
--              [ LEFT ]                [CENTER]                 [RIGHT]
--┌────────────────────────────────────────────────────────────────────────────┐
--│ ┌───────────┐  ┌─────────┐      ┌──────────┐     ┌──────────┐  ┌─────────┐ │
--│ │  CONTROL  │  │  MEDIA  │      │  WINDOW  │     │  STATUS  │  │  STATE  │ │
--│ └───────────┘  └─────────┘      └──────────┘     └──────────┘  └─────────┘ │
--└────────────────────────────────────────────────────────────────────────────┘
-- Outer box is transparent and just a layout container. The layout has three
-- sections, each one containing 1-2 visible bars.

--- @param s screen
function M.create(s)
  local height = theme.spacing(12)

  local box = wibox {
    position = "top",
    ontop = true,
    screen = s,
    type = "dock",
    height = height,
    width = s.geometry.width,
    x = s.geometry.x,
    y = s.geometry.y,
    stretch = true,
    visible = true,
    bg = theme.transparent,
  }

  box:struts {
    top = height,
  }

  box:setup(ui.margin(theme.spacing(2)) {
    layout = wibox.layout.align.horizontal,
    expand = "none", -- Center widget will get the most space

    ui.horizontal {
      spacing = theme.spacing(4),
      bg = theme.transparent,
      children = {
        control_bar.build(),
        media_bar.build(),
      },
    },
    ui.horizontal {
      spacing = theme.spacing(4),
      bg = theme.transparent,
      children = {
        window_bar.build(),
      },
    },
    ui.horizontal {
      spacing = theme.spacing(4),
      bg = theme.transparent,
      children = {
        status_bar.build(),
        state_bar.build(),
      },
    },
  })

  return box
end

--- @param s screen | nil
function M.hide(s)
  local scr = s or awful.screen.focused {}
  if scr then
    scr.bar.visible = false
  end
end

--- @param s screen | nil
function M.show(s)
  local scr = s or awful.screen.focused {}
  if scr then
    scr.bar.visible = true
  end
end

--- @param s screen | nil
function M.toggle(s)
  local scr = s or awful.screen.focused {}
  if scr then
    scr.bar.visible = not scr.bar.visible
  end
end

return M
