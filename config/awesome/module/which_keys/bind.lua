local class = require("module.class")
local theme = require("theme").which_key

---@alias modifier
---| '"Shift"' # Shift
---| '"Control"' # Ctrl
---| '"Mod1"' # Alt
---| '"Mod4"' # Super

---@class BindColor
---@field key_bg string
---@field key_fg string
---@field action_bg string
---@field action_fg string

---@class KeybindDetails
---@field description string|nil -- Action label.
---@field which_key_key string|nil -- Override the key label.
---@field which_key_color string|nil -- Override the default color.
---@field which_key_hidden boolean|nil -- Set hidden to true or false.
---@field which_key_sticky boolean|nil -- Set action to be sticky or not. Sticky actions will not exit the chord after being triggered..

---@class Bind
---@field key_label string -- Label of full keycombo, ex. "Ctrl+a".
---@field action_label string -- Label of the action to take, ex. "+clients".
---@field action function() -- Action to trigger.
---@field colors BindColor -- Colors of this bind.
---@field is_hidden boolean -- If this bind should be excluded from showing up in popups.
---@field is_sticky boolean -- If this bind should be sticky or not.
---@field sort_key string -- Key to use when sorting by.
local Bind = class()

---@param modifiers table<number,modifier> | '"none"' -- Modifiers for this keybind.
---@param key string -- The actual key, ex. '"a"'.
---@return string, string
local function key_label_and_sort(modifiers, key)
  local aliases = {
    [" "] = "SPC",
    Control = "C",
    Shift = "S",
    Mod1 = "A",
    Mod4 = ""
  }

  -- Convert list of modifiers into a lookup table
  local mods = {}
  local mods_count = 0
  for _, mod in ipairs(modifiers) do
    mods_count = mods_count + 1
    mods[mod] = true
  end

  -- Unshifted keys should be sorted before shifted keys.
  local sort_key = string.lower(key)
  if mods_count == 1 and mods.Shift then
    sort_key = sort_key .. "2"
  elseif mods_count >= 1 then
    sort_key = sort_key .. "3"
  else
    sort_key = sort_key .. "1"
  end

  -- Key is not a symbol, but rather a letter. Enable special treatment of "Shift".
  local label = ""
  if string.len(key) == 1 and string.lower(key) ~= string.upper(key) then
    if mods.Shift then
      mods.Shift = nil
      label = string.upper(key)
    else
      label = string.lower(key)
    end
  else
    -- Look for an alias for the key
    label = aliases[key] or key
    -- Non-letters should be sorted last
    sort_key = "z9" .. sort_key
  end

  local mods_label = ""
  -- Mods should end up in a consistent order in the modifiers string:
  -- Mod4, Shift, Control, Mod1
  if mods.Mod4 then mods_label = mods_label .. aliases.Mod4 end
  if mods.Shift then mods_label = mods_label .. aliases.Shift end
  if mods.Control then mods_label = mods_label .. aliases.Control end
  if mods.Mod1 then mods_label = mods_label .. aliases.Mod1 end
  if string.len(mods_label) > 0 then
    label = mods_label .. "-" .. label
  end

  return label, sort_key
end

---@param modifiers table<number,modifier> | '"none"' -- Modifiers for this keybind.
---@param key string -- The actual key, ex. '"a"'.
---@param action function() -- Function to trigger on this keybind.
---@param details KeybindDetails? -- Extra details about the keybind.
function Bind:initialize(modifiers, key, action, details)
  self.modifiers = modifiers
  self.key = key
  self.action = action
  self.details = details or {}

  self.is_hidden = self.details.which_key_hidden or false
  self.is_sticky = self.details.which_key_sticky or false

  self.key_label, self.sort_key = key_label_and_sort(modifiers, key)
  self.action_label = self.details.description or "no-description"
  self.colors = self.details.which_key_colors

  if self.is_sticky then
    self.colors = self.colors or theme.sticky
  else
    self.colors = self.colors or theme.normal
  end
end

return Bind
