local awful = require "awful"

local function start(...)
  awful.spawn.once(...)
end

local M = {}

function M.early()
  -- Don't auto-start anything in test mode or when restarting.
  if is_test_mode() or is_awesome_restart() then
    return
  end

  start {
    "picom",
    "--config",
    os.getenv "HOME" .. "/.config/picom/picom.conf",
  }
end

function M.late()
  -- Don't auto-start anything in test mode or when restarting.
  if is_test_mode() or is_awesome_restart() then
    return
  end

  start "dynamic-startup"
end

return M
