local wibox = require "wibox"
local awful = require "awful"

local theme = require "module.theme"
local ui = require "widgets.ui"

local tag_list = require "widgets.bars.tag_list"
local media = require "widgets.bars.media"
local clock = require "widgets.bars.clock"

local M = {}

-- Layout of the bar:
--[ LEFT ]                   [CENTER]                          [RIGHT]
--┌──────────────────────────────────────────────────────────────────┐
--│┌────┐┌───────┐                             ┌─────┐┌──────┐┌─────┐│
--││TAGS││WINDOWS│                             │MEDIA││STATUS││CLOCK││
--│└────┘└───────┘                             └─────┘└──────┘└─────┘│
--└──────────────────────────────────────────────────────────────────┘

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
    bg = theme.background,
  }

  box:struts {
    top = height,
  }

  box:setup {
    layout = wibox.layout.align.horizontal,

    ui.horizontal {
      spacing = theme.spacing(4),
      bg = theme.transparent,
      children = {
        tag_list.build(s),
        ui.placeholder(theme.crust, "windows"),
      },
    },
    nil,
    ui.horizontal {
      spacing = theme.spacing(4),
      bg = theme.transparent,
      children = {
        awful.widget.only_on_screen(media.build(s), "primary"),
        ui.placeholder(theme.crust, "statuses"),
        clock.build(s),
      },
    },
  }

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