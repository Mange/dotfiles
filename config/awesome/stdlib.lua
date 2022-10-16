--- @alias ModuleInitializerFunction fun(): CleanupFunction | nil
--- @alias CleanupFunction fun()

--- @class screen
--- @field geometry {x: number, y: number, width: number, height: number}
--- @field bar widget

--- @class widget

local gears = require "gears"
local xresources = require "beautiful.xresources"

--- Returns a pixel value scaled for the current screen DPI.
--- @param px number Size in pixels
--- @return number Size in pixels scaled for the current DPI
function _G.dpi(px)
  return xresources.apply_dpi(px)
end

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

--- @class LoadedModule
--- @field initialized boolean
--- @field cleanup CleanupFunction | nil

--- @type table<string, LoadedModule>
local loaded_modules = {}
--- @type string[]
local module_order = {}

--- @param name string
--- @return boolean
function _G.cleanup_module(name)
  if loaded_modules[name] then
    local cleanup = loaded_modules[name].cleanup
    if cleanup then
      cleanup()
    end
    loaded_modules[name] = nil
    package.loaded[name] = nil

    return true
  end

  package.loaded[name] = nil
  return false
end

--- Require and set up a module. If called multiple times, the module will
--- still only be set up once.
---
--- The module must export a `initialize` function that may return a cleanup
--- function. This cleanup function will be called if the module is reloaded.
---
--- @param name string -- Module name
--- @return unknown
function _G.require_module(name)
  local module = require(name)

  if type(module) ~= "table" then
    gears.debug.print_error("Module " .. name .. " did not return a module!")
    return module
  end

  if loaded_modules[name] then
    return module
  end

  local loaded = {
    initialized = false,
    cleanup = nil,
  }
  loaded_modules[name] = loaded
  module_order[#module_order + 1] = name

  if type(module.initialize) == "function" then
    loaded.initialized = true
    loaded.cleanup = module.initialize()
  end

  return module
end

function _G.reload_modules()
  local modules = module_order
  module_order = {}

  -- Unload modules in reverse order…
  for i = #modules, 1, -1 do
    cleanup_module(modules[i])
  end

  -- …and read them again in normal order
  for i = 1, #modules do
    reload(modules[i])
  end
end

function _G.cleanup_modules()
  -- Unload modules in reverse order…
  for i = #module_order, 1, -1 do
    cleanup_module(module_order[i])
  end

  module_order = {}
end

--- A `require` that reloads the module if it was already loaded.
--- Useful in REPL to be able to test changes to your module without restarting
--- Awesome.
---
--- @param name string -- Module name
--- @return unknown
function _G.reload(name)
  local was_module = cleanup_module(name)
  package.loaded[name] = nil

  if was_module then
    return require_module(name)
  else
    return require(name)
  end
end
