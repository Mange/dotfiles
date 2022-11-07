-- Setup Luarocks
pcall(require, "luarocks.loader")

-- Make AwesomeWM / Lua use the configured locale
os.setlocale(os.getenv "LANG")

local naughty = require "naughty"
local gears = require "gears"

--
-- Error handling
--
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
  gears.debug.print_error "Startup error detected:"
  gears.debug.dump(awesome.startup_errors, "error")

  naughty.notify {
    preset = naughty.config.presets.critical,
    title = "Oops, there were errors during startup!",
    text = awesome.startup_errors,
  }
end
-- Handle runtime errors after startup
do
  local in_error = false
  awesome.connect_signal("debug::error", function(err)
    -- Make sure we don't go into an endless error loop
    if in_error then
      return
    end
    in_error = true

    gears.debug.print_error "debug::error event:"
    gears.debug.dump(err, "err")

    naughty.notify {
      preset = naughty.config.presets.critical,
      title = "Oops, an error happened!",
      text = tostring(err),
    }
    in_error = false
  end)
end

--
-- Setup restart detection.
--
-- xproperties are persisted on Awesome restarts, which means we can put a
-- value here on startup and then all restarts will be able to read it out.
awesome.register_xproperty("awesome_initialized", "boolean")
local restart_detected = awesome.get_xproperty "awesome_initialized" ~= nil
awesome.set_xproperty("awesome_initialized", true)

--- Returns true if Awesome WM is being restarted.
--- @return boolean
function _G.is_awesome_restart()
  return restart_detected
end
