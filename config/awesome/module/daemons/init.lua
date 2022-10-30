require "module.daemons.battery"
require "module.daemons.brightness"
require "module.daemons.picom"
require "module.daemons.profile"
require "module.daemons.volume"
require "module.daemons.workrave"

return {
  initialize = function()
    require_module "module.daemons.playerctl"

    return function() end
  end,
}
