local wibox = require "wibox"
local awful = require "awful"
local gears = require "gears"

local theme = require "module.theme"
local ui = require "widgets.ui"

local clock_format = '<span font="'
  .. theme.font_bold
  .. '">%-d %b %H:%M</span>'

local M = {}

function M.initialize()
  return function() end
end

--- @param s screen
function M.build(s)
  local clock = wibox.widget {
    widget = wibox.widget.textclock,
    format = clock_format,
  }

  local clock_tooltip = awful.tooltip {
    mode = "outside",
    delay_show = 1,
    preferred_positions = { "right", "left", "top", "bottom" },
    preferred_alignments = { "middle", "front", "back" },
    margin_leftright = theme.spacing(2),
    margin_topbottom = theme.spacing(2),
    timer_function = function()
      return os.date "Idag är det <b>%A</b> den <b>%d %B</b> (v<b>%V</b>)"
    end,
  }

  local month_calendar = awful.widget.calendar_popup.month {
    start_sunday = false,
    week_numbers = true,
    spacing = dpi(5),
    font = theme.font_size(10),
    long_weekdays = true,
    margin = dpi(5),
    screen = s,
    style_month = {
      border_width = dpi(0),
      bg_color = theme.background,
      padding = dpi(20),
      shape = function(cr, width, height)
        gears.shape.partially_rounded_rect(
          cr,
          width,
          height,
          true,
          true,
          true,
          true,
          dpi(7)
        )
      end,
    },
    style_header = {
      border_width = 0,
      bg_color = theme.transparent,
    },
    style_weeknumber = {
      border_width = 0,
      bg_color = theme.transparent,
    },
    style_weekday = {
      border_width = 0,
      bg_color = theme.transparent,
    },
    style_normal = {
      border_width = 0,
      bg_color = theme.transparent,
    },
    style_focus = {
      border_width = dpi(0),
      border_color = theme.fg_normal,
      bg_color = theme.accent,
      shape = function(cr, width, height)
        gears.shape.partially_rounded_rect(
          cr,
          width,
          height,
          true,
          true,
          true,
          true,
          dpi(4)
        )
      end,
    },
  }

  local button = ui.button {
    bg = theme.transparent,
    on_left_click = function()
      clock_tooltip.visible = false
    end,
    child = ui.margin(0, theme.spacing(2))(clock),
  }

  clock_tooltip:add_to_object(button)
  month_calendar:attach(button, "tr", {
    on_hover = false,
  })

  return button
end

return M
