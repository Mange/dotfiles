-- Try to detect screen "focus" change.
-- https://github.com/awesomeWM/awesome/pull/2219
-- Monkey patch to detect when explicitly changing focus to a different screen.
local awful = require "awful"
local original_method = awful.screen.focus
awful.screen.focus = function(...)
  local old_screen = awful.screen.focused()
  local result = original_method(...)
  local new_screen = awful.screen.focused()
  if old_screen.index ~= new_screen.index then
    new_screen:emit_signal "mange:focus"
  end

  return result
end
