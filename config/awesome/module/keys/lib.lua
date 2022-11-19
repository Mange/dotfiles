local gears = require "gears"

local M = {}

-- Overridable for tests
if _G.is_test then
  -- awful.key returns a table of the binds in all possible combinations of
  -- modifiers that are ignored. Like NumLock and ScrollLock.
  -- Emulate by wrapping the single table in a table.
  M.awful_key = function(...)
    return { { ... } }
  end
else
  local awful = require "awful"
  M.awful_key = awful.key
end

---@alias modifier
---| '"Shift"' # Shift
---| '"Control"' # Ctrl
---| '"Mod1"' # Alt
---| '"Mod4"' # Super

---@class ActionWithName
---@field [1] fun()
---@field [2] string

---@alias Mapping ActionWithName
---@alias Mappings table<string, Mapping>

--- @class KeyBind
--- @field [1] string[] Modifier keys
--- @field [2] string Key

M.aliases = {
  mod = "Mod4",
  shift = "Shift",
  ctrl = "Control",
  control = "Control",

  left = "Left",
  right = "Right",
  up = "Up",
  down = "Down",
  tab = "Tab",
  backspace = "BackSpace",
  ["return"] = "Return",

  plus = "+",
}

--- @param strings string[]
--- @return string[]
local function replace_aliases(strings)
  local mapped = {}

  for _, str in ipairs(strings) do
    if M.aliases[string.lower(str)] then
      table.insert(mapped, M.aliases[string.lower(str)])
    else
      table.insert(mapped, str)
    end
  end

  return mapped
end

--- @param bind string
--- @return KeyBind
function M.parse_bind(bind)
  local parts = replace_aliases(gears.string.split(bind, "+"))
  local key = table.remove(parts, #parts)
  local modifiers = parts

  -- Since non-letters (like 1 and +) are the same in lower and uppercase,
  -- don't react on them here as an implied Shift key.
  if key == string.upper(key) and string.lower(key) ~= string.upper(key) then
    table.insert(modifiers, "Shift")
    key = string.lower(key)
  end

  return { parts, key }
end

--- @param mappings Mappings
function M.build_awful_keys(mappings)
  local keys = {}

  for bind, opts in pairs(mappings) do
    local action = opts[1]
    if action ~= nil then
      local key = M.parse_bind(bind)
      local description = opts[2]
      opts.description = description
      opts[1] = nil
      opts[2] = nil

      keys = gears.table.join(keys, M.awful_key(key[1], key[2], action, opts))
    end
  end

  return keys
end

return M
