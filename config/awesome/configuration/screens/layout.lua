-- This file tries to dynamically figure out my multiscreen layout and place
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

local bling = require "vendor.bling"
local utils = require "utils"

local function is_portrait(s)
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

local screen_layout = {}

function screen_layout.get_layout()
  -- Handle xrandr edge case of no screen being the primary one
  local primary = screen.primary or screen[1]

  return {
    main = primary,
    reference = left_of(primary),
    comms = right_of(primary),
  }
end

function screen_layout.is_portrait(s)
  return is_portrait(s)
end

function screen_layout.apply_wallpaper_overrides()
  local current = screen_layout.current

  for _, type in ipairs { "main", "reference", "comms" } do
    local s = current[type]
    local layout = is_portrait(s) and "portrait" or "landscape"

    s.wallpaper_override = utils.first_wallpaper_path {
      type .. "_" .. layout .. ".jpg",
      type .. ".jpg",
      layout .. ".jpg",
    }
  end
end

function screen_layout.layout_rotation(layout, screen)
  local landscapes = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.fair,
    bling.layout.vertical,
  }

  local portraits = {
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair.horizontal,
    bling.layout.horizontal,
  }

  if is_portrait(screen) then
    -- Find layouts that only make sense for landscape and rotate them
    for i, landscape in ipairs(landscapes) do
      if layout == landscape then
        return portraits[i]
      end
    end
  else
    -- Find layouts that only make sense for portrait and rotate them
    for i, portrait in ipairs(portraits) do
      if layout == portrait then
        return landscapes[i]
      end
    end
  end

  return layout
end

function screen_layout.refresh()
  screen_layout.current = screen_layout.get_layout()
  screen_layout.apply_wallpaper_overrides()
end

screen_layout.refresh()
return screen_layout
