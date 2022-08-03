-- local awful = require('awful')
local beautiful = require "beautiful"
local wibox = require "wibox"
local gears = require "gears"
-- local icons = require('theme.icons')
local dpi = require("utils").dpi
-- local clickable_container = require('widgets.clickable-container')
local tasklist = require "widgets.tasklist"
local taglist = require "widgets.taglist"

local top_panel = function(s)
  local panel = wibox {
    position = "top",
    ontop = true,
    screen = s,
    type = "dock",
    height = dpi(48),
    width = s.geometry.width,
    x = s.geometry.x,
    y = s.geometry.y,
    stretch = true,
    bg = beautiful.background,
    fg = beautiful.fg_normal,
    visible = true,
  }

  panel:struts {
    top = dpi(48),
  }

  panel:connect_signal("mouse::enter", function()
    local w = mouse.current_wibox
    if w then
      w.cursor = "left_ptr"
    end
  end)

  local build_widget = function(widget)
    return wibox.widget {
      widget = wibox.container.margin,
      top = dpi(9),
      bottom = dpi(9),
      {
        widget = wibox.container.background,
        border_width = dpi(1),
        border_color = beautiful.groups.title_bg,
        bg = beautiful.transparent,
        shape = function(cr, w, h)
          gears.shape.rounded_rect(cr, w, h, dpi(12))
        end,
        widget,
      },
    }
  end

  s.systray = wibox.widget {
    {
      base_size = dpi(20),
      horizontal = true,
      screen = "primary",
      widget = wibox.widget.systray,
    },
    visible = true,
    top = dpi(10),
    widget = wibox.container.margin,
  }

  -- local add_button     = build_widget(require('widget.open-default-app')(s))
  -- s.search_apps      = build_widget(require('widget.search-apps')())
  s.chord_start = build_widget(require "widgets.chord-start")
  s.control_center_toggle = build_widget(
    require "widgets.control-center-toggle"(s)
  )
  -- s.global_search      = build_widget(require('widget.global-search')())
  -- s.info_center_toggle   = build_widget(require('widget.info-center-toggle')())
  s.tray_toggler = build_widget(require "widgets.tray-toggle")
  -- s.updater         = build_widget(require('widget.package-updater')())
  -- s.screen_rec       = build_widget(require('widget.screen-recorder')())
  -- s.bluetooth         = build_widget(require('widget.bluetooth')())
  -- s.network           = build_widget(require('widget.network')())
  local clock = build_widget(require "widgets.clock"(s))
  local layout_box = build_widget(require "widgets.layoutbox"(s))
  s.battery = build_widget(require "widgets.battery"())
  -- s.info_center_toggle  = build_widget(require('widget.info-center-toggle')())

  panel:setup {
    {
      layout = wibox.layout.align.horizontal,
      expand = "none",
      {
        layout = wibox.layout.fixed.horizontal,
        spacing = dpi(5),
        -- s.search_apps,
        s.chord_start,
        s.control_center_toggle,
        -- s.global_search,
        build_widget(taglist(s)),
        build_widget(tasklist(s)),
        -- add_button
      },
      nil,
      {
        layout = wibox.layout.fixed.horizontal,
        spacing = dpi(5),
        {
          s.systray,
          margins = dpi(5),
          widget = wibox.container.margin,
        },
        s.tray_toggler,
        -- s.updater,
        -- s.screen_rec,
        -- s.network,
        -- s.bluetooth,
        s.battery,
        clock,
        layout_box,
        -- s.info_center_toggle
      },
    },
    left = dpi(5),
    right = dpi(5),
    widget = wibox.container.margin,
  }

  return panel
end

return top_panel
