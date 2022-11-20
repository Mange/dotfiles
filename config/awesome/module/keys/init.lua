local lib = require "module.keys.lib"

local M = {
  -- Initialize when module is initialized, not when it is loaded.
  -- This allows us to reload the module when we want to.
  global = {},
  clients = {},
}

--- @param is_reload boolean
function M.module_initialize(is_reload)
  if is_reload then
    unload "configuration.keys"
  end

  local config = require "configuration.keys"

  M.global = lib.build_awful_keys(config.global)
  M.clients = lib.build_awful_keys(config.clients)

  -- Setup the global keys
  root.keys(M.global)

  return function()
    root.keys {}
  end
end

return M
