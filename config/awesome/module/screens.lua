-- This module tries to dynamically figure out my multiscreen layout and place
-- tags and things that makes the most sense in it.
--
-- I have some general rules of thumbs that I try to follow, and this file
-- tries to maintain them. They are as follows:
--
--   1. Primary screen in the middle.
--   2. If more than one screen, then place references and communications
--      around the primary.
--   3. If three screens, then reference to the left and comms to the right.
--
-- I also use portrait monitors sometimes, which affects wallpaper selection
-- among other things.
--
-- This file looks at the screens and points my different roles to the best
-- available screen.

local utils = require "utils"
local awful = require "awful"

--- @alias ScreenType "main" | "reference" | "comms"

local function is_portrait(s)
  if not s then
    return false
  end
  return s.geometry.height > s.geometry.width
end

local function left_of(of)
  local most_left = of

  for s in screen do
    if s.geometry.x < most_left.geometry.x then
      most_left = s
    end
  end

  return most_left
end

local function right_of(of)
  local most_right = of

  for s in screen do
    if s.geometry.x > most_right.geometry.x then
      most_right = s
    end
  end

  return most_right
end

local M = {}

function M.get_layout()
  -- Handle xrandr edge case of no screen being the primary one
  local primary = screen.primary or screen[1]

  return {
    main = primary,
    reference = left_of(primary),
    comms = right_of(primary),
  }
end

function M.apply_wallpaper_overrides()
  local current = M.current

  for _, type in ipairs { "main", "reference", "comms" } do
    local s = current[type]
    if s then
      local layout = is_portrait(s) and "portrait" or "landscape"

      s.wallpaper_override = utils.first_wallpaper_path {
        type .. "_" .. layout .. ".jpg",
        type .. ".jpg",
        layout .. ".jpg",
      }
    end
  end
end

--- @param type ScreenType
function M.find_screen(type)
  return M.current[type] or M.current.main
end

function M.module_initialize()
  local refresh_layout = function()
    M.current = M.get_layout()
    M.apply_wallpaper_overrides()
  end

  refresh_layout()

  -- When a screen is added, and for all currently added screens
  awful.screen.connect_for_each_screen(refresh_layout)
  -- When a screen changes geometry
  screen.connect_signal("property::geometry", refresh_layout)

  return function()
    screen.disconnect_signal("property::geometry", refresh_layout)
    awful.screen.disconnect_for_each_screen(refresh_layout)
  end
end

return M
