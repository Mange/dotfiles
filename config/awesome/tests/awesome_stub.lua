local stubs = {}

local function awesome_base_object(name, object)
  object.connect_signal = function(...) end
  object.set_index_miss_handler = function(...) end
  object.set_newindex_miss_handler = function(...) end

  stubs[name] = object
  if _G[name] == nil then
    _G[name] = object
  end

  return object
end

local awesome = awesome_base_object("awesome", {
  register_xproperty = function(...) end,
  get_xproperty = function(...) end,
  set_xproperty = function(...) end,
  api_level = 4,
  themes_path = "/usr/share/awesome/themes",
  icon_path = "/usr/share/awesome/icons",
})

local client = awesome_base_object("client", {
  get = function(...) return {} end,
})

local screen = awesome_base_object("screen", {})
local tag = awesome_base_object("tag", {})
local key = awesome_base_object("key", {})
local drawin = awesome_base_object("drawin", {})

local mouse = awesome_base_object("mouse", {
  coords = function() return 0, 0 end,
})

local root = awesome_base_object("root", {
  size = function(...) return 1920, 1080 end,
  size_mm = function(...) return 598, 336 end,
  keys = {},
  buttons = {},
  cursor = function(...) end
})

local button = awesome_base_object("button", {})
setmetatable(button, {
  __call = function(...)
    return {
      _private = {},
      connect_signal = function(...) end,
    }
  end
})

return stubs
