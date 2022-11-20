--- @alias ModuleInitializerFunction fun(is_reload: boolean): CleanupFunction | nil
--- @alias CleanupFunction fun()

--- @class screen
--- @field geometry {x: number, y: number, width: number, height: number}
--- @field bar widget

--- @class widget
--- @field get_children_by_id(string): widget[]
--- @field connect_signal(string)
--- @field disconnect_signal(string)

local gears = require "gears"
local xresources = require "beautiful.xresources"

_G.Mouse = {
  left_click = 1,
  middle_click = 2,
  right_click = 3,
  scroll_up = 4,
  scroll_down = 5,
}

_G.Key = {
  super = "Mod4",
}

--- Keep track of all cleanups that have been registered and in which order so
--we can run them globally.
--- @type table[]
local modules_to_clean_up = {}

--- @param cleanups unknown
local function run_cleanups(cleanups)
  if type(cleanups) == "table" then
    -- Run cleanup functions in reverse order
    for i = #cleanups, 1, -1 do
      if type(cleanups[i]) == "function" then
        cleanups[i]()
      end
    end
  end
end

--- @param mod table
local function cleanup_module(mod)
  run_cleanups(mod["__module_cleanups"])
  mod["__module_cleanups"] = nil
end

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

--- @generic M : table
--- @param module M
--- @param is_reload? boolean
--- @return M
function _G.initialize_module(module, is_reload)
  if type(module) ~= "table" then
    error "Module is not a table!"
  end

  if type(module["module_initialize"]) == "function" then
    local cleanup = module["module_initialize"](is_reload or false)
    if type(cleanup) == "function" then
      on_module_cleanup(module, cleanup)
    end
  end
  return module
end

--- @generic M : table
--- @param module M
--- @param cleanup_function fun()
function _G.on_module_cleanup(module, cleanup_function)
  if module["__module_cleanups"] == nil then
    module["__module_cleanups"] = {}
  end

  table.insert(module["__module_cleanups"], cleanup_function)
  table.insert(modules_to_clean_up, module)
end

--- Remove a module from the list of loaded modules. The next time it is
--- required it will be loaded from disk again.
---
--- @param name string -- Module name
function _G.unload(name)
  local mod = package.loaded[name]

  if mod then
    cleanup_module(mod)
  end

  package.loaded[name] = nil
end

--- A `require` that reloads the module if it was already loaded.
--- Useful in REPL to be able to test changes to your module without restarting
--- Awesome.
---
--- @param name string -- Module name
--- @return unknown
function _G.reload(name)
  unload(name)
  return initialize_module(require(name))
end

-- Unload modules when Awesome is restarted. This makes sure that modules that
-- spawn processes and whatnot also can restart properly.
awesome.connect_signal("exit", function(is_restart)
  if is_restart then
    for i = #modules_to_clean_up, 1, -1 do
      cleanup_module(modules_to_clean_up[i])
      modules_to_clean_up[i] = nil
    end
    modules_to_clean_up = {}
  end
end)
