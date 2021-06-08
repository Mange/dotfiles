local awful = require("awful")
local fs = require("gears.filesystem")
local timer = require("gears.timer")

local utils = require("utils")

local blur_config_path = fs.get_xdg_config_home() .. "/picom/blur.cfg"

local picom = {
  blur_strength = 8,
  default_blur_strength = 8,
  min_blur_strength = 1, -- A value of "0" seems to be using 5 as the parsed value
  max_blur_strength = 15,
}

-- Picom can crash if it's reloaded too quickly. Rate limit reloads of it!
local picom_reload_debounce = timer {
  timeout = 0.8,
  call_now = false,
  autostart = false,
  single_shot = true,
  callback = function()
    -- Send signal to picom to reload config
    awful.spawn({"killall", "-USR1", "picom"}, false)
  end
}

local function picom_reload()
  picom_reload_debounce:again()
end

local function write_blur_strength()
  local content = "strength = " .. tostring(picom.blur_strength) .. ".0;"
  local file = io.open(blur_config_path, "w")
  file:write(content)
  file:close()
  picom_reload()
end

local function emit_blur_strength_signal()
  awesome.emit_signal("mange:picom:update_blur_strength", picom.blur_strength)
end

function picom:set_blur_strength(value)
  local strength = utils.clamp(picom.min_blur_strength, value, picom.max_blur_strength)

  self.blur_strength = strength
  write_blur_strength()
  emit_blur_strength_signal()
end

function picom:change_blur_strength(delta)
  picom:set_blur_strength(picom.blur_strength + delta)
end

function picom:reload_blur_strength()
  local file = io.open(blur_config_path, "r")
  local content = file:read()
  file:close()
  self.blur_strength = tonumber(string.match(content, "(%d+)"))
  emit_blur_strength_signal()
end

function picom:on_update_blur_strength(func)
  awesome.connect_signal("mange:picom:update_blur_strength", func)
end

return picom
