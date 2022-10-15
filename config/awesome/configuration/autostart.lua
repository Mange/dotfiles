local awful = require "awful"

local function start(...)
  awful.spawn.once(...)
end

local M = {
  early = function()
    -- Don't auto-start anything in test mode or when restarting.
    if is_test_mode() or is_awesome_restart() then
      return function() end
    end

    start {
      "picom",
      "--config",
      os.getenv "HOME" .. "/.config/picom/picom.conf",
      "--experimental-backends",
    }
  end,

  late = function()
    -- Don't auto-start anything in test mode or when restarting.
    if is_test_mode() or is_awesome_restart() then
      return function() end
    end

    start "dynamic-startup"
  end,
}

return M
