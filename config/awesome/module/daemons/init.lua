require "module.daemons.battery"
require "module.daemons.brightness"
require "module.daemons.picom"
require "module.daemons.profile"
require "module.daemons.volume"
require "module.daemons.workrave"

local M = {}

--- @param is_reload boolean
function M.module_initialize(is_reload)
  initialize_module(require "module.daemons.playerctl", is_reload)
end

return M
