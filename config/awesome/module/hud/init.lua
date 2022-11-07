local bars = require "widgets.bars"

local M = {}

local function setup(s)
  s.bar = bars.create(s)
end

local function cleanup(s)
  s.bar = nil
end

function M.module_initialize()
  screen.connect_signal("request::desktop_decoration", setup)

  return function()
    screen.disconnect_signal("request::desktop_decoration", setup)
    for s in screen do
      cleanup(s)
    end
  end
end

return M
