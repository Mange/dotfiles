local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

local gruvbox = require("colors").gruvbox
local utils = require("utils")
local actions = require("actions")
local keys = require("keys")

local volume_widget = {}

local function get_icon(volume, is_mute)
  if is_mute then
    return "ﱝ"
  elseif volume >= 80 then
    return ""
  elseif volume >= 40 then
    return ""
  else
    return ""
  end
end

local function get_arc_values(volume, is_mute)
  local color

  if is_mute then
    color = gruvbox.dark3
  else
    color = gruvbox.light0
  end

  -- If volume is >100%, then add a "overflow" arc value.
  -- For example, consider 112% volume. Then the "normal" value should be 100 -
  -- 12 = 78. The remaining 12 is now the "overflow", with its own color.
  -- The overflow needs to come first in order to appear to grow on top of a
  -- full normal circle.
  if volume > 100 then
    local overflow = volume - 100 -- 112 - 100 = 12
    return {overflow, 100 - overflow}, {gruvbox.bright_red, color}
  else
    return {volume}, {color}
  end
end

function volume_widget.new()
  local text = wibox.widget {
    widget = wibox.widget.textbox,
    text = get_icon(50, false),
    align = "center",
    valign = "center"
  }

  -- Mirror text since the arcchart will be mirrored
  local text_on_bg = wibox.widget {
    widget = wibox.container.background,
    wibox.container.mirror(text, { horizontal = true })
  }

  local widget = wibox.widget {
    widget = wibox.container.arcchart,
    max_value = 100,
    rounded_edge = true,
    border_width = 0,
    thickness = utils.dpi(2),
    paddings = 2,
    start_angle = math.rad(270), -- Start on top
    text_on_bg,
  }

  local function update(data)
    local vol = math.max(data.volume_left, data.volume_right)
    widget.value = vol
    text.text = get_icon(vol, data.is_mute)
    widget.values, widget.colors = get_arc_values(vol, data.is_mute)
  end

  awesome.connect_signal("mange:volume:update", function(data) update(data) end)

  widget:buttons(
    gears.table.join(
      awful.button({}, keys.left_click, actions.volume_mute_toggle()),
      awful.button({}, keys.right_click, actions.volume_tui()),
      awful.button({}, keys.middle_click, actions.volume_gui()),
      awful.button({}, keys.scroll_up, actions.volume_change("+5")),
      awful.button({}, keys.scroll_down, actions.volume_change("-5")),
      awful.button({"shift"}, keys.right_click, actions.volume_gui())
    )
  )

  -- Mirror the widget, so that chart value increases clockwise
  return wibox.container.mirror(widget, { horizontal = true })
end

return volume_widget
