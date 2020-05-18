local awful = require("awful")
local gears = require("gears")

-- xproperties are persisted on Awesome restarts, which means we can put a
-- value here on startup and then all restarts will be able to read it out.
awesome.register_xproperty("awesome_restart_check", "boolean")
local restart_detected = awesome.get_xproperty("awesome_restart_check") ~= nil
awesome.set_xproperty("awesome_restart_check", true)

local utils = {}

function utils.run_or_raise(cmd, matchers)
  for _, c in ipairs(client.get()) do
    if c and awful.rules.match(c, matchers) then
      c:jump_to()
      return
    end
  end

  awful.spawn(cmd)
end

function utils.on_first_start(func)
  if not restart_detected then
    func()
  end
end

function utils.on_restart(func)
  if restart_detected then
    func()
  end
end

function utils.set_wallpaper(s, wallpaper)
    if wallpaper then
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

return utils
