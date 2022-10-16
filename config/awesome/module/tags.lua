local awful = require "awful"
local gears = require "gears"
local sharedtags = require "sharedtags"
local bling = require "vendor.bling"

--- @module "module.screens"
local screen_layout = require_module "module.screens"

--- @param config TagConfig
local function create_tag(config)
  -- Find screen it should be on
  local screen = screen_layout.find_screen(config.screen_type or "main")

  local tag = gears.table.join(config, {
    screen = screen.index,
  })

  -- Automatically rotate layout for the screen selection
  -- tag_definition.layout = screen_layout.layout_rotation(
  --   tag_definition.layout or default_layout,
  --   screen
  -- )

  return tag
end

local function setup_tags()
  --- @module "configuration.tags"
  local configs = reload "configuration.tags"
  local tags = gears.table.map(create_tag, configs)

  return sharedtags(tags)
end

-- Table of layouts to cover with awful.layout.inc, order matters.
local function setup_layouts()
  awful.layout.layouts = {
    bling.layout.centered,

    -- awful.layout.suit.floating,     -- All windows are floating
    awful.layout.suit.tile, -- Master + Stack, with Master on Left
    awful.layout.suit.tile.left, -- Master + Stack, with Master on Right
    -- awful.layout.suit.tile.bottom,  -- Master + Stack, with Master on Bottom
    awful.layout.suit.tile.top, -- Master + Stack, with Master on Top
    bling.layout.equalarea,
    awful.layout.suit.fair, -- Grid (Vertical)
    awful.layout.suit.fair.horizontal, -- Grid (Horizontal)
    -- awful.layout.suit.spiral,       -- Fibonacci
    awful.layout.suit.spiral.dwindle, -- BSP
    bling.layout.mstab, -- Tabbed
    awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier, -- Master floating center
    bling.layout.deck,
    -- awful.layout.suit.corner.nw,    -- Master + two stacks below and to the side
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
    bling.layout.vertical,
    bling.layout.horizontal,
  }
end

local M = {
  tags = setup_tags(),
}

--- @type ModuleInitializerFunction
function M.initialize()
  M.tags = setup_tags()
  tag.connect_signal("request::default_layouts", setup_layouts)

  -- If restarting, then the request::default_layouts have already been
  -- processed. Manually override directly.
  if is_awesome_restart() then
    setup_layouts()
  end

  return function()
    tag.disconnect_signal("request::default_layouts", setup_layouts)
  end
end

return M
