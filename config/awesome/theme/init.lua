local gears = require("gears")
local gruvbox = require("../colors").gruvbox
local dpi = require("utils").dpi

local default_theme = assert(
  loadfile(gears.filesystem.get_themes_dir() .. "default/theme.lua")
)()

local theme = {}

gears.table.crush(theme, default_theme)

--
-- OLD CONFIG
--
-- Setup gaps
theme.useless_gap = 8
theme.gap_single_client = false

theme.bg_normal     = gruvbox.dark2
theme.bg_focus      = gruvbox.neutral_purple
theme.bg_urgent     = gruvbox.bright_red
theme.bg_minimize   = gruvbox.dark2

theme.fg_focus      = gruvbox.light0
theme.fg_urgent     = gruvbox.light1
theme.fg_minimize   = gruvbox.light1

theme.border_width  = 3
theme.border_normal = gruvbox.dark3
theme.border_focus  = gruvbox.neutral_purple
theme.border_marked = gruvbox.faded_yellow

theme.titlebar_bg_normal = gruvbox.dark3 .. "70"
theme.titlebar_bg_focus  = gruvbox.neutral_purple .. "70"

theme.wibar_border_width = 0
theme.wibar_bg = gruvbox.dark0 .. "55"
theme.wibar_fg = gruvbox.light1

theme.taglist_bg_focus = gruvbox.faded_purple .. "cc"
theme.taglist_bg_urgent = gruvbox.faded_orange .. "55"

theme.tasklist_bg_normal = "transparent"
theme.tasklist_bg_focus = gruvbox.faded_purple .. "cc"
theme.tasklist_bg_urgent = gruvbox.faded_orange .. "55"

theme.wallpaper = gears.filesystem.get_xdg_data_home() .. "wallpapers/current.jpg"

theme.notification_icon_size = utils.dpi(96)
theme.notification_bg = gruvbox.dark0.."99"

--
-- NEW CONFIG (WIP)
--

---@param base string
---@param opacity string
---@return string
local opacity = function(base, opacity)
  if string.len(base) > 7 then
    return base:sub(1, 7) .. opacity
  else
    return base .. opacity
  end
end

local black = "#000000"
local white = "#ffffff"
local transparent = opacity(black, "00")

---@param size integer
theme.font_size = function(size)
  theme.font = "Fira Sans Regular " .. size
end

theme.font = theme.font_size(11)
theme.font_bold = "Fira Sans Extra Bold 11"

theme.groups = {
  bg = opacity(white, "10"),
  title_bg = opacity(white, "15"),
  radius = dpi(9),
}

theme.events = {
  leave = transparent,
  press = opacity(white, "15"),
  release = opacity(white, "10")
}

theme.transparent = transparent
theme.background = opacity(black, "66")
theme.fg_normal = opacity(white, "de")
theme.accent = gruvbox.faded_blue

theme.bg_systray = theme.background -- Looks horrible
theme.systray_icon_spacing = dpi(16)

return theme
