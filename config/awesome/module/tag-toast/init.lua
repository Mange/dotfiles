local naughty = require "naughty"
local gears = require "gears"

local theme = require "theme"

local notification = nil

local show_tag_toast = function(s)
  local tags = s.selected_tags
  local first_tag = tags[1]
  if first_tag then
    local text = table.concat(
      gears.table.map(function(t)
        return t.name
      end, tags),
      " + "
    )

    if notification then
      notification:destroy(naughty.notification_closed_reason.silent)
    end

    notification = naughty.notification {
      title = nil,
      text = text,
      urgency = "low",
      category = "x-mange.toast",
      screen = s,
      preset = theme.toast,
      position = theme.toast.position,
      icon = first_tag.icon,
      timeout = 0.7,
    }
  end
end

tag.connect_signal("property::selected", function(t)
  show_tag_toast(t.screen)
end)

screen.connect_signal("mange:focus", function(s)
  show_tag_toast(s)
end)
