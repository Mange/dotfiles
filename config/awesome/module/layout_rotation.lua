-- One layout that works well in landscape might be really bad on a portrait
-- screen, and the other way around.
-- This module "rotates" those specific layouts everytime a tag is moved to a
-- different screen, or whenever a screen changed geometry.

local bling = require "vendor.bling"
local awful = require "awful"

local function is_portrait(s)
  if not s then
    return false
  end

  return s.geometry.height > s.geometry.width
end

local function rotate_layout(layout, screen)
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

local M = {}

function M.module_initialize(is_reload)
  local apply_rotation = function(t)
    if t.layout and t.screen then
      t.layout = rotate_layout(t.layout, t.screen)
    end
  end

  -- Theres' no attached_disconnect_signal so don't clean this up. On the other
  -- hand, it's no problem to not support cleanup of this module and require a
  -- full restart instead.
  if not is_reload then
    awful.tag.attached_connect_signal(nil, "property::screen", apply_rotation)
  end
end

return M
