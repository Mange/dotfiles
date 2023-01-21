local beautiful = require "beautiful"
local gears = require "gears"
local icons = require "theme.icons"

local black = "#000000"
local white = "#ffffff"
local transparent = "#00000000"

-- Catppuccin Mocha
local rosewater = "#f5e0dc"
local flamingo = "#f2cdcd"
local pink = "#f5c2e7"
local mauve = "#cba6f7"
local red = "#f38ba8"
local maroon = "#eba0ac"
local peach = "#fab387"
local yellow = "#f9e2af"
local green = "#a6e3a1"
local teal = "#94e2d5"
local sky = "#89dceb"
local sapphire = "#74c7ec"
local blue = "#89b4fa"
local lavender = "#b4befe"
local text = "#cdd6f4"
local subtext1 = "#bac2de"
local subtext0 = "#a6adc8"
local overlay2 = "#9399b2"
local overlay1 = "#7f849c"
local overlay0 = "#6c7086"
local surface2 = "#585b70"
local surface1 = "#45475a"
local surface0 = "#313244"
local base = "#1e1e2e"
local mantle = "#181825"
local crust = "#11111b"

local default_theme =
  assert(loadfile(gears.filesystem.get_themes_dir() .. "default/theme.lua"))()

local theme = gears.table.clone(default_theme)

--- @param color string
--- @param opacity_hex string
--- @return string
local function opacity(color, opacity_hex)
  if string.len(color) > 7 then
    return color:sub(1, 7) .. opacity_hex
  else
    return color .. opacity_hex
  end
end

--- Return a multiple of a standard spacing.
---
--- @param size number
--- @return number
function theme.spacing(size)
  return dpi(size * 4)
end

---@param size integer
theme.font_size = function(size)
  return "Overpass " .. size
end

---@param size integer
theme.font_bold_size = function(size)
  return "Overpass ExtraBold " .. size
end

---@param size integer
theme.font_mono_size = function(size)
  return "Jetbrains Mono " .. size
end

theme.rm = function(ratio)
  return round(ratio * 11)
end

theme.font = theme.font_size(theme.rm(1))
theme.font_bold = theme.font_bold_size(theme.rm(1))
theme.font_mono = theme.font_mono_size(theme.rm(1))

-- Icons
theme.icons = icons.dir
theme.icon = icons
theme.awesome_icon = theme.icons .. "awesome.svg"
theme.icon_theme = "Tela"

-- Base
theme.transparent = transparent
theme.rosewater = rosewater
theme.flamingo = flamingo
theme.pink = pink
theme.mauve = mauve
theme.red = red
theme.maroon = maroon
theme.peach = peach
theme.yellow = yellow
theme.green = green
theme.teal = teal
theme.sky = sky
theme.sapphire = sapphire
theme.blue = blue
theme.lavender = lavender
theme.text = text
theme.subtext1 = subtext1
theme.subtext0 = subtext0
theme.overlay2 = overlay2
theme.overlay1 = overlay1
theme.overlay0 = overlay0
theme.surface2 = surface2
theme.surface1 = surface1
theme.surface0 = surface0
theme.base = base
theme.mantle = mantle
theme.crust = crust

theme.background = mantle

theme.rainbow_colors = {
  lavender,
  blue,
  sapphire,
  sky,
  teal,
  green,
  yellow,
  peach,
  maroon,
  red,
}

--- @param index number
--- @return string
theme.rainbow = function(index)
  return theme.rainbow_colors[index % #theme.rainbow_colors + 1]
end

theme.opacity = opacity

-- Wallpaper
theme.wallpaper = gears.filesystem.get_xdg_data_home()
  .. "wallpapers/landscape.jpg"

-- Bling layouts
theme.mstab_dont_resize_slaves = true
theme.mstab_tabbar_style = "default"
theme.mstab_bar_padding = 0
theme.mstab_border_radius = 0

-- Which Key
-- TODO: Update colors
theme.which_key = {
  bg = theme.background,
  title_fg = "#E91E63",

  normal = {
    key_bg = theme.accent,
    key_fg = white,
    action_bg = white,
    action_fg = theme.accent,
  },
  nested = {
    key_bg = "#E91E63",
    key_fg = white,
    action_bg = white,
    action_fg = black,
  },
  sticky = {
    key_bg = "#00ff00",
    key_fg = white,
    action_bg = white,
    action_fg = "#00aa00",
  },
}

-- Tasklist
theme.tasklist_plain_task_name = true -- Disable icons for floating, minimized, etc.

theme.tasklist_fg_normal = theme.subtext0
theme.tasklist_bg_normal = theme.transparent

theme.tasklist_fg_focus = theme.rosewater
theme.tasklist_bg_focus = theme.transparent

theme.tasklist_fg_urgent = theme.peach
theme.tasklist_bg_urgent = theme.surface0

-------------------

function theme.module_initialize()
  beautiful.init(theme)
end

return theme
