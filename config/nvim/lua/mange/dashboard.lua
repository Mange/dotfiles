-- local home = os.getenv "HOME"
local db = require "dashboard"

-- db.preview_command = "wezterm"
-- db.preview_file_path = home .. "/.config/nvim/dashboard.png"
-- db.preview_file_width = 80
-- db.preview_file_height = 12
-- db.image_width_pixel = 80
-- db.image_height_pixel = 12

db.custom_center = {
  {
    icon = "  ",
    desc = "Find file                               ",
    action = "Telescope find_files",
    shortcut = "SPC p f",
  },
  {
    icon = "  ",
    desc = "Browse files                            ",
    action = "Telescope file_browser",
    shortcut = "      -",
  },
  {
    icon = "  ",
    desc = "New file                                ",
    action = "DashboardNewFile",
    shortcut = "SPC b n",
  },
  {
    icon = "  ",
    desc = "Load session                            ",
    shortcut = "SPC S l",
    action = "SessionLoad",
  },
}
