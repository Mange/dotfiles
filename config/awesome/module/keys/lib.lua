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

local byte_a = 97
local byte_z = 122
local byte_A = 65
local byte_Z = 90

local function is_letter(s)
  if type(s) == "string" and string.len(s) == 1 then
    local byte = string.byte(s)
    return (byte >= byte_a and byte <= byte_z)
      or (byte >= byte_A and byte <= byte_Z)
  else
    return false
  end
end

M.aliases = {
  super = "Mod4",
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

M.display_aliases = {
  mod4 = "M",
  shift = "S",
  control = "C",
  backspace = "BS",
  space = "Space",
  ["+"] = "Plus",
  ["-"] = "Minus",
}

--- @param strings string[]
--- @param aliases table<string, string>
--- @return string[]
local function replace_aliases(strings, aliases)
  local mapped = {}

  for _, str in ipairs(strings) do
    local lower = string.lower(str)
    if aliases[lower] then
      table.insert(mapped, aliases[lower])
    else
      table.insert(mapped, str)
    end
  end

  return mapped
end

--- @param bind string
--- @return KeyBind
function M.parse_bind(bind)
  local parts = replace_aliases(gears.string.split(bind, "+"), M.aliases)
  local key = table.remove(parts, #parts)
  local modifiers = parts

  -- Capitalized letters implies shift ("ctrl+S" => "ctrl+shift+s")
  if is_letter(key) and key == string.upper(key) then
    table.insert(modifiers, "Shift")
    key = string.lower(key)
  end

  return { parts, key }
end

--- @param bind KeyBind
--- @return string
function M.stringify_bind(bind)
  local modifiers = bind[1]
  local key = bind[2]

  local parts = {}

  for _, modifier in ipairs(modifiers) do
    -- If modifier is shift and key is a letter, then uppercase the letter
    -- instead.
    if modifier == "Shift" and is_letter(key) then
      key = string.upper(key)
    else
      table.insert(parts, modifier)
    end
  end

  table.insert(parts, key)

  return table.concat(replace_aliases(parts, M.display_aliases), "-")
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
