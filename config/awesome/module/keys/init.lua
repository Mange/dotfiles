local lib = require "module.keys.lib"

local M = {}

--- @param is_reload boolean
function M.module_initialize(is_reload)
  if is_reload then
    unload "configuration.keys"
  end

  local config = require "configuration.keys"
  local global = lib.build_awful_keys(config.global)

  root.keys(global)

  return function() end
end

return M
