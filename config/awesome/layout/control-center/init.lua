local beautiful = require('beautiful')
local wibox = require('wibox')

local dpi = require("utils").dpi

local format_item = function(widget)
  return wibox.widget {
    {
      {
        layout = wibox.layout.align.vertical,
        expand = 'none',
        nil,
        widget,
        nil
      },
      margins = dpi(10),
      widget = wibox.container.margin
    },
    forced_height = dpi(88),
    border_width = dpi(1),
    border_color = beautiful.groups_title_bg,
    bg = beautiful.groups_bg,
    shape = function(cr, width, height)
      gears.shape.rounded_rect(cr, width, height, beautiful.groups_radius)
    end,
    widget = wibox.container.background
  }
end

local placeholder = function()
  return format_item({
    widget = wibox.widget.textbox,
    align = "center",
    valign = "center",
    markup = "HELLO WORLD",
  })
end

local control_center = function(s)
  local width = dpi(400)
  local panel = awful.popup {
    screen = s,
    type = "dock",
    visible = true, -- TODO: Default to false
    ontop = true,
    width = width,
    maximum_width = width,
    maximum_height = dpi(s.geometry.height - 60),
    bg = beautiful.transparent,
    fg = beautiful.fg_normal,
    shape = gears.shape.rectangle,
    widget = {
      id = "control_center",
      border_width = dpi(1),
      border_color = beautiful.groups_title_bg,
      bg = beautiful.background,
      shape = function(cr, w, h)
        gears.shape.rounded_rect(cr, w, h, beautiful.groups_radius)
      end,
      widget = wibox.container.background,
      {
        widget = wibox.container.margin,
        margins = dpi(16),
        {
          layout = wibox.layout.fixed.vertical,
          spacing = dpi(10),
          {
            layout = wibox.layout.stack,
            {
              id = "main_control",
              visible = true,
              layout = wibox.layout.fixed.vertical,
              spacing = dpi(10),
              placeholder(),
            },
            {
              id = "monitor_control",
              visible = true,
              layout = wibox.layout.fixed.vertical,
              spacing = dpi(10),
              placeholder(),
            },
          },
          placeholder(),
        },
      },
    },
  }

  panel:connect_signal(
    "property::height",
    function()
      awful.placement.top_left(
        panel,
        {
          honor_workarea = true,
          margins = {
            top = dpi(5),
            left = dpi(5),
          },
        }
      )
    end
  )

  function panel:open()
    self.visible = true
    panel:emit_signal("opened")
  end

  function panel:close()
    self.visible = false
    panel:emit_signal("closed")
  end

  function panel:toggle()
    if self.visible then
      panel:close()
    else
      panel:open()
    end
  end

  return panel
end

return control_center
