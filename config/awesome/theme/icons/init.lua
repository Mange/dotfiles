-- Most icons come from https://tabler-icons.io/

-- Icons directory
local dir = os.getenv "HOME" .. "/.config/awesome/theme/icons/"

local taglist = dir .. "tag-list/"

return {
  dir = dir,

  -- Action Bar
  device_desktop = taglist .. "device-desktop.svg",
  code = taglist .. "code.svg",
  terminal_2 = taglist .. "terminal-2.svg",
  world = taglist .. "world.svg",
  notebook = taglist .. "notebook.svg",
  square_6 = taglist .. "square-6.svg",
  square_7 = taglist .. "square-7.svg",
  brand_steam = taglist .. "brand-steam.svg",
  brand_telegram = taglist .. "brand-telegram.svg",
  playlist = taglist .. "playlist.svg",

  -- Others/System UI
  close = dir .. "close.svg",
  logout = dir .. "logout.svg",
  sleep = dir .. "power-sleep.svg",
  power = dir .. "power.svg",
  lock = dir .. "lock.svg",
  restart = dir .. "restart.svg",
  search = dir .. "magnify.svg",
  volume = dir .. "volume-high.svg",
  volume_high = dir .. "volume-high.svg",
  volume_medium = dir .. "volume-medium.svg",
  volume_low = dir .. "volume-low.svg",
  volume_off = dir .. "volume-off.svg",
  brightness = dir .. "brightness-7.svg",
  effects = dir .. "effects.svg",
  chart = dir .. "chart-areaspline.svg",
  memory = dir .. "memory.svg",
  harddisk = dir .. "harddisk.svg",
  thermometer = dir .. "thermometer.svg",
  plus = dir .. "plus.svg",
  batt_charging = dir .. "battery-charge.svg",
  batt_discharging = dir .. "battery-discharge.svg",
  toggled_on = dir .. "toggled-on.svg",
  toggled_off = dir .. "toggled-off.svg",

  -- Default profile image
  default_profile_image = dir .. "default_profile_image.svg",
}
