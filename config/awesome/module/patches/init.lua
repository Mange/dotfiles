local awful = require "awful"
local original_method = awful.screen.focus

-- Try to detect screen "focus" change.
-- https://github.com/awesomeWM/awesome/pull/2219
-- Monkey patch to detect when explicitly changing focus to a different screen.
local function patched_focus(...)
  local old_screen = awful.screen.focused()
  local result = original_method(...)
  local new_screen = awful.screen.focused()
  if old_screen.index ~= new_screen.index then
    new_screen:emit_signal "mange:focus"
  end

  return result
end

local M = {}

function M.module_initialize()
  awful.screen.focus = patched_focus

  return function()
    awful.screen.focus = original_method
  end
end

return M
