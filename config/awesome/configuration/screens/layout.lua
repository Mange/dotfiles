-- I try to support most screen layouts I could be using and place tags and
-- workspaces dynamically.
--
-- Generally I try to have the largest screen as primary, then other screens
-- around it.
--
-- Most common layouts:
--  * H layout (two portraits around a central wide - which is primary)
--  * Twin layout (two wide)
--  * Single screen layout
--  * ┤ or ├ layouts (one portrait next to primary wide)
--
-- This module tries to detect which configuration I'm running and return
-- standardized destinations for tags, clients, etc. to be used in the other
-- parts of this config.

local utils = require("utils")

local function single_layout()
  return {
    name = "single",
    main = screen.primary,
    reference = screen.primary,
    comms = screen.primary,
  }
end

local function twin_layout()
  return {
    name = "twin",
    main = screen[1],
    reference = screen[2],
    comms = screen[2],
  }
end

local function find_rest(primary)
  local rest = {}
  local i = 1

  for s in screen do
    if not (s == primary) then
      rest[i] = s
      i = i + 1
    end
  end

  return rest
end

function is_portrait(s)
  return s.geometry.height > s.geometry.width
end

function left(screens)
  local most_left = screens[1]

  for s in screens do
    if s.geometry.x < most_left.geometry.x then
      most_left = s
    end
  end

  return most_left
end

function right(screens)
  local most_right = screens[1]

  for s in screens do
    if s.geometry.x > most_right.geometry.x then
      most_right = s
    end
  end

  return most_right
end

local screen_layout = {
  current = nil,
}

function screen_layout.get_layout()
  local count = screen.count()

  if count < 2 then
    return single_layout()
  elseif count == 2 then
    return twin_layout()
  end

  local primary = screen.primary
  local rest = find_rest(primary)

  -- Detect H layout
  if count == 3 and is_portrait(rest[1]) and is_portrait(rest[2]) then
    return {
      name = "H",
      main = primary,
      reference = rest[1],
      comms = rest[2],
    }
  end

  return {
    name = "generic",
    main = primary,
    reference = left(rest),
    comms = right(rest),
  }
end

function screen_layout.is_portrait(s)
  return is_portrait(s)
end

function screen_layout.apply_wallpaper_overrides(layout)
  local main_portrait = utils.wallpaper_path("wallhaven-eyq6zr.jpg")

  for s in screen do
    if is_portrait(s) then
      s.wallpaper_override = main_portrait
    else
      s.wallpaper_override = nil
    end
  end

  -- If H layout, comms have a different portrait wallpaper
  if layout.name == "H" then
    layout.comms.wallpaper_override = utils.wallpaper_path("wallhaven-r21q37.jpg")
  end
end

function screen_layout.tag_layout_rotation(t)
  local landscapes = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.fair,
  }

  local portraits = {
    awful.layout.suit.tile.top,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.fair.horizontal,
  }

  if is_portrait(t.screen) then
    -- Find layouts that only make sense for landscape and rotate them
    for i, layout in ipairs(landscapes) do
      if t.layout == layout then
        t.layout = portraits[i]
        break
      end
    end
  else
    -- Find layouts that only make sense for portrait and rotate them
    for i, layout in ipairs(portraits) do
      if t.layout == layout then
        t.layout = landscapes[i]
        break
      end
    end
  end
end

function screen_layout.refresh()
  screen_layout.current = screen_layout.get_layout()
  screen_layout.apply_wallpaper_overrides(screen_layout.current)
end

screen_layout.refresh()

return screen_layout
