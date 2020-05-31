local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

local keys = require("keys")

return function(opts)
  local interval = opts.interval or 10

  local widget = wibox.widget {
    widget = wibox.widget.textbox,
    text = "…",
  }

  local function compose_update(func)
    return function(...)
      local result = func(...)
      -- Command that runs might not have time to affect the command right
      -- away, so give it a few milliseconds before we update.
      gears.timer.start_new(
        0.2,
        function()
          widget.update()
          return false
        end
      )
      return result
    end
  end

  local buttons = gears.table.join(
    awful.button({"Shift"}, keys.left_click, function() widget.update() end)
  )

  if opts.left_click then
    buttons = gears.table.join(buttons, awful.button({}, keys.left_click, compose_update(opts.left_click)))
  end

  if opts.right_click then
    buttons = gears.table.join(buttons, awful.button({}, keys.right_click, compose_update(opts.right_click)))
  end

  if opts.middle_click then
    buttons = gears.table.join(buttons, awful.button({}, keys.middle_click, compose_update(opts.middle_click)))
  end

  widget:buttons(buttons)

  local set_widget_text = function(line)
    widget.text = line
  end

  local function widget_loop()
    awful.spawn.with_line_callback(
      opts.command,
      {
        stdout = set_widget_text,
        stderr = set_widget_text,
        exit = function(reason, code)
          if reason == "exit" and code ~= 0 then
            -- Try again with extra delay
            gears.timer.start_new((interval + 1) * 2, widget_loop)
          else
            gears.timer.start_new(interval, widget_loop)
          end
        end
      }
    )
  end

  function widget.update()
    -- Not a refreshing command (e.g. "tail command"), so don't try to start it
    -- up again.
    if opts.interval == 0 then
      return
    end

    awful.spawn.with_line_callback(
      opts.command,
      {
        stdout = set_widget_text,
        stderr = set_widget_text,
      }
    )
  end

  widget_loop()

  return widget
end
