local lib = require "keys.lib"

local M = {}

--- @param is_reload boolean
function M.module_initialize(is_reload)
  if is_reload then
    unload "configuration.keys"
  end

  local keys = require "configuration.keys"

  inspect(keys.global)
  -- root.keys(keys.global)

  return function() end
end

return M
