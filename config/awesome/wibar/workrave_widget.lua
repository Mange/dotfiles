-- TODO: Add some keybindings to it to pause, etc.
-- TODO: Is it possible to add a hover-popup showing the real times?

local wibox = require("wibox")

local gruvbox = require("colors").gruvbox
local utils = require("utils")

local icon_name = "/home/mange/.config/awesome/icons/workrave-gray.png"
local workrave_widget = {}

local function make_arcwidget()
  local text = wibox.widget {
    widget = wibox.widget.textbox,
    text = "",
    font = "Fira Sans Regular 9", -- TODO: DRY this up (changing from default 11 to 9)
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

  -- Mirror the widget, so that chart value increases clockwise
  local final = wibox.container.mirror(widget, { horizontal = true })

  -- Consider remaining decreasing as "time to a break" increasing; e.g. for
  -- each second the value should increase by 1.
  final.update = function(timer)
    local total = timer.remaining + timer.elapsed
    local percent = (100 * timer.elapsed / total)
    widget.max_value = total
    widget.value = timer.elapsed

    if timer.overdue > 10 then
      text.text = math.floor(timer.overdue / 60)
      widget.colors = {gruvbox.bright_red}
    else
      if timer.remaining > 60 then
        text.text = math.floor(timer.remaining / 60)
      else
        text.text = math.floor(timer.remaining)
      end

      if percent > 90 then
        widget.colors = {gruvbox.bright_yellow}
      else
        widget.colors = {gruvbox.light0}
      end
    end
  end

  return final
end

function workrave_widget.new()
  local micro_widget = make_arcwidget()
  local rest_widget = make_arcwidget()

  local widget = wibox.widget {
    layout = wibox.layout.flex.horizontal,
    visible = false,
    wibox.widget {
      widget = wibox.widget.imagebox,
      resize = true,
      image = icon_name,
    },
    micro_widget,
    wibox.widget {
      widget = wibox.container.margin,
      left = utils.dpi(4),
      rest_widget
    }
  }

  awesome.connect_signal("mange:workrave:update", function(data)
    widget.visible = true
    micro_widget.update(data.micro)
    rest_widget.update(data.rest)
  end)

  return widget
end

return workrave_widget
