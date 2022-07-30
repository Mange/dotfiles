local bling = require "vendor.bling"

-- Table of layouts to cover with awful.layout.inc, order matters.
tag.connect_signal("request::default_layouts", function()
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
end)
