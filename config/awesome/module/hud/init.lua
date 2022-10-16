--- @module "widgets.bars"
local bars = require_module "widgets.bars"

local function setup_hud(s)
  s.bar = bars.create(s)
end

local function cleanup_hud(s)
  s.bar = nil
end

return {
  --- @type ModuleInitializerFunction
  initialize = function()
    screen.connect_signal("request::desktop_decoration", setup_hud)
    return function()
      screen.disconnect_signal("request::desktop_decoration", setup_hud)
      for s in screen do
        cleanup_hud(s)
      end
      cleanup_module "widgets.bars"
    end
  end,
}
