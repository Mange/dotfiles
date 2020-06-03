local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

local keys = require("keys")

return function(opts)
  local interval = opts.interval or 10
  local tail = opts.interval == 0

  local widget = wibox.widget {
    widget = wibox.widget.textbox,
    -- Start with empty text for commands that do early exit without printing
    -- anything, e.g. "Not applicable on this machine", or "Nothing to show
    -- right now"
    text = ""
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
    widget.markup = string.gsub(
      string.gsub(line, "%%{F(#[^}]*)}", "<span foreground=\"%1\">"),
      "%%{F%-}", "</span>"
    )
  end

  local function widget_loop()
    awful.spawn.with_line_callback(
      opts.command,
      {
        stdout = set_widget_text,
        stderr = set_widget_text,
        exit = function(reason, code)
          if tail then
            if reason == "exit" and code ~= 0 then
              -- Script is not supposed to exit, and it failed. Let's give it
              -- some time and then try again.
              gears.timer.start_new(30, widget_loop)
            end
            -- Do nothing if exiting successfully. We assume this means the
            -- script is not applicable for this machine.
          else
            -- Script is now done. Wait for a delay and try again.
            if reason == "exit" and code ~= 0 then
              -- Try again with extra delay
              gears.timer.start_new(interval * 2, widget_loop)
            else
              gears.timer.start_new(interval, widget_loop)
            end
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
