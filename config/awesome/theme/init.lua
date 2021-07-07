local gears = require("gears")
local gruvbox = require("../colors").gruvbox
local dpi = require("utils").dpi
local icons = require("theme.icons")

local default_theme = assert(
  loadfile(gears.filesystem.get_themes_dir() .. "default/theme.lua")
)()

local theme = {}

gears.table.crush(theme, default_theme)

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
  return "Fira Sans Regular " .. size
end

---@param size integer
theme.font_bold_size = function(size)
  return "Fira Sans Extra Bold " .. size
end

---@param size integer
theme.font_mono_size = function(size)
  return "Fira Code " .. size
end

theme.font = theme.font_size(11)
theme.font_bold = theme.font_bold_size(11)
theme.font_mono = theme.font_mono_size(11)

-- Icons
theme.icons = icons.dir
theme.awesome_icon = theme.icons .. "awesome.svg"
theme.icon_theme = "Tela"

-- Base
theme.transparent = transparent
theme.background = opacity(black, "66")
theme.accent = gruvbox.faded_blue

-- Foreground
theme.fg_normal = opacity(white, "de")
theme.fg_focus = "#e4e4e4"
theme.fg_urgent = "#cc9393"

-- Background
theme.bg_normal = theme.background
theme.bg_focus = "#5a5a5a"
theme.bg_urgent = "#3f3f3f"

-- Borders
theme.border_focus = opacity("#563238", "ff")
theme.border_normal = opacity("#29353b", "00")
theme.border_marked = "#cc9393"
theme.border_width = dpi(2)
theme.border_radius = dpi(9)

-- Decorations
theme.useless_gap = 8
theme.gap_single_client = false
theme.client_shape_rectangle = gears.shape.rectangle
theme.client_shape_rounded = function(cr, width, height)
  gears.shape.rounded_rect(cr, width, height, dpi(9))
end

-- Groups
theme.groups = {
  bg = opacity(white, "10"),
  title_bg = opacity(white, "15"),
  radius = dpi(9),
  shape = function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, beautiful.groups.radius)
  end,
}

-- Events
theme.events = {
  leave = transparent,
  enter = opacity(white, "10"),
  press = opacity(white, "15"),
  release = opacity(white, "10")
}

-- Menu
theme.menu_font = theme.font_size(11)
theme.menu_submenu = '' -- ➤

theme.menu_height = dpi(34)
theme.menu_width = dpi(200)
theme.menu_border_width = dpi(20)
theme.menu_bg_focus = opacity(theme.accent, 'cc')

theme.menu_bg_normal = opacity(theme.background, "33")
theme.menu_fg_normal = white
theme.menu_fg_focus = white
theme.menu_border_color = opacity(theme.background, "5c")

-- Tooltips
theme.tooltip_bg = theme.background
theme.tooltip_border_color = transparent
theme.tooltip_border_width = dpi(0)
theme.tooltip_gaps = dpi(5)
theme.tooltip_shape = function(cr, w, h)
  gears.shape.rounded_rect(cr, w, h, dpi(6))
end

-- Separators
theme.separator_color = opacity("#f2f2f2", "44")

-- Layoutbox icons
theme.layout_max = theme.icons .. 'layouts/max.svg'
theme.layout_tile = theme.icons .. 'layouts/tile.svg'
theme.layout_dwindle = theme.icons .. 'layouts/dwindle.svg'
theme.layout_floating = theme.icons .. 'layouts/floating.svg'

-- Taglist
theme.taglist_bg_empty = opacity(theme.background, '00')
theme.taglist_bg_occupied = opacity(white, "1a")
theme.taglist_bg_urgent = opacity("#E91E63", 99)
theme.taglist_bg_focus = theme.background
theme.taglist_spacing = dpi(0)

-- Tasklist
theme.tasklist_font = theme.font_size(10)

theme.tasklist_fg_normal = "#aaaaaa"
theme.tasklist_bg_normal = opacity(theme.background, "99")

theme.tasklist_fg_focus = "#dddddd"
theme.tasklist_bg_focus = theme.background

theme.tasklist_fg_urgent = white
theme.tasklist_bg_urgent = opacity("#E91E63", "99")

theme.tasklist_fg_minimize = "#888888"
theme.tasklist_bg_minimize = opacity(theme.background, "22")

-- Notification
theme.notification_position = "top_right"
theme.notification_bg = transparent
theme.notification_margin = dpi(5)
theme.notification_border_width = dpi(0)
theme.notification_border_color = transparent
theme.notification_spacing = dpi(5)
theme.notification_icon_resize_strategy = "center"
theme.notification_icon_size = dpi(32)

theme.toast = {
  font = theme.font_size(33),
  position = "middle",
  bg = opacity(theme.background, "22"),
  margin = dpi(5),
  border_width = dpi(0),
  border_color = transparent,
  spacing = dpi(5),
  icon_resize_strategy = "center",
  icon_size = dpi(48),
}

theme.which_key = {
  bg = theme.background,
  title_fg = "#E91E63",
  key_bg = "#E91E63",
  key_fg = white,
  action_bg = white,
  action_fg = black,
}

-- Client Snap Theme
theme.snap_bg = theme.background
theme.snap_shape = gears.shape.rectangle
theme.snap_border_width = dpi(15)

-- Hotkey popup
theme.hotkeys_font = theme.font_bold
theme.hotkeys_description_font = theme.font
theme.hotkeys_bg = theme.background
theme.hotkeys_group_margin = dpi(20)

-- Systray
theme.bg_systray = theme.background -- Looks horrible
theme.systray_icon_spacing = dpi(16)

-- Wallpaper
theme.wallpaper = gears.filesystem.get_xdg_data_home() .. "wallpapers/current.jpg"

return theme
