--- @alias ModuleInitializerFunction fun(): CleanupFunction | nil
--- @alias CleanupFunction fun()

local gears = require "gears"

--- Returns true if running in "test mode". Test mode is both for unit tests
--- and when running inside AWMTT.
---
--- Set this up by having the IN_AWMTT environment variable set to "yes" or by
--- setting `_G.is_test` to `true`.
--- @return boolean
function _G.is_test_mode()
  return _G.is_test or os.getenv "IN_AWMTT" == "yes"
end

--- Returns a string that inspects a value. Useful for logging and printing
--- debug statements.
---
--- @param val any -- Value to inspect
--- @param tag string -- Name of inspected value
--- @param depth number? -- Maximum depth when inspecting values
--- @return string
function _G.inspect(val, tag, depth)
  return gears.debug.dump_return(val, tag, depth)
end

--- A `require` that reloads the module if it was already loaded.
--- Useful in REPL to be able to test changes to your module without restarting
--- Awesome.
---
--- @param name string -- Module name
--- @return unknown
function _G.reload(name)
  package.loaded[name] = nil
  return require(name)
end

--- @type table<string, CleanupFunction>
local module_cleanup_functions = {}

--- Require and set up a module. If called again, then the module will be
--- cleaned up and reloaded.
---
--- The module must export a `initialize` function that may return a cleanup
--- function. This cleanup function will be called if the module is reloaded.
---
--- @param name string -- Module name
--- @return unknown
function _G.setup_module(name)
  if module_cleanup_functions[name] then
    local cleanup = module_cleanup_functions[name]
    cleanup()
    module_cleanup_functions[name] = nil
  end

  local module = reload(name)

  if type(module) ~= "table" then
    gears.debug.print_error("Module " .. name .. " did not return a module!")
    return module
  end

  if type(module.initialize) == "function" then
    local cleanup = module.initialize()
    if type(cleanup) == "function" then
      module_cleanup_functions[name] = cleanup
    end
  end

  return module
end
