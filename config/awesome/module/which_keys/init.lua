--
-- Combine keyboard grabber and a popup menu showing the available bindings.
-- This is trying to replicate Emacs' Hydra/ShowKey / Vim's which-key.
--
-- Used like this:
-- local media_chord = which_keys.new_chord(
--   "Media",
--   {
--    keybindings = {
--      {{}, "k", playerctl("play-pause"), {description = "Play/pause", group = "Player"}}
--    },
--    timeout = 5,
--  }
-- )
-- media_chord.enter()

-- TODO:
--   * Allow clicking on entries to trigger them
--   * Add close button on top right for mouse usage
--   * Add suport for custom widget between title and columns
--     * Media mode should show media information widget, for example.
--

local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

local keys = require("module.constants.keys")
local clickable_container = require("widgets.clickable-container")
local icons = require("theme.icons")
local dpi = require("utils").dpi
local Bind = require("module.which_keys.bind")

local style = {
  font_header = beautiful.font_bold_size(18),
  font = beautiful.font_size(14),
  font_mono = beautiful.font_mono_size(14),
}

local aliases_to_keys = {
  Space = " ",
  space = " "
}

---@class Chord
---@field binds Bind[]
---@field title string
---@field enter function()
---@field stop function()
---@field show_popup function()
---@field hide_popup function()

---@alias Widget table

---@class Keybind
---@field 1 table<number,modifier> | '"none"' -- Modifiers for this keybind.
---@field 2 string -- The actual key, ex. '"a"'.
---@field 3 function() -- Function to trigger on this keybind.
---@field 4 KeybindDetails? -- Extra details about the keybind.

---@param binds Bind[]
---@param num_columns number
---@return Bind[][]
-- Place Binds into num_columns columns, in this fashion:
-- [
--  [1, 4, 7],
--  [2, 5, 8],
--  [3, 6]
-- ]
local function group_binds_into_columns(binds, num_columns)
  local columns = {}
  for i = 1, num_columns do
    columns[i] = {}
  end

  local column_index = 1
  local current_column = columns[column_index]

  for _, bind in ipairs(binds) do
    if not bind.is_hidden then
      current_column[#current_column+1] = bind

      column_index = column_index + 1
      if column_index > num_columns then
        column_index = 1
      end
      current_column = columns[column_index]
    end
  end

  return columns
end

local which_keys = {}

-- Generate pango markup to change foreground color for the given text.
local function fg(color, text)
  return "<span foreground=\"" .. tostring(color) .. "\">" .. tostring(text) .. "</span>"
end

---@param margins number
---@param widget Widget
---@return Widget
local function margin(margins, widget)
  return {
    widget = wibox.container.margin,
    margins = margins,
    widget
  }
end

---@vararg Widget
---@return Widget
local function vertical(...)
  return {
    widget = wibox.layout.fixed.vertical,
    ...
  }
end

---@param left Widget
---@param center Widget
---@param right Widget
---@return Widget
local function align_horizontal(left, center, right)
  return {
    widget = wibox.layout.align.horizontal,
    left, center, right
  }
end

---@param title string
---@return Widget
local function title_widget(title)
  return {
    widget = wibox.widget.textbox,
    markup = fg(beautiful.which_key.title_fg, string.upper(title)),
    font = style.font_header,
    align = "center"
  }
end

---@param bind Bind
---@return Widget
local function entry_widget(bind)
  local widget = wibox.widget {
    widget = wibox.container.margin,
    top = dpi(5),
    bottom = dpi(5),
    {
      widget = wibox.layout.fixed.horizontal,
      {
        -- Key
        widget = wibox.container.background,
        bg = bind.colors.key_bg,
        fg = bind.colors.key_fg,
        {
          widget = wibox.container.margin,
          left = dpi(5),
          right = dpi(5),
          {
            widget = wibox.widget.textbox,
            text = bind.key_label,
            align = "center",
            ellipsize = "start",
            font = style.font_mono
          }
        }
      },
      -- Action
      {
        widget = wibox.container.background,
        bg = bind.colors.action_bg,
        fg = bind.colors.action_fg,
        {
          widget = wibox.container.margin,
          left = dpi(5),
          right = dpi(5),
          {
            widget = wibox.widget.textbox,
            text = bind.action_label,
            align = "left",
            ellipsize = "end",
            font = style.font
          }
        }
      }
    }
  }
  widget:add_button(
    awful.button(
      {}, keys.left_click, nil, bind.action
    )
  )
  return widget
end

---@param column Bind[]
---@return Widget
local function column_widget(column)
  local entries = {}
  for i, bind in ipairs(column) do
    entries[i] = entry_widget(bind)
  end

  return vertical(table.unpack(entries))
end

---@return Widget
local function close_button(instance)
  local button = wibox.widget {
    widget = clickable_container,
    margin(dpi(10), {
      widget = wibox.widget.imagebox,
      image = icons.close,
      resize = true,
      valign = "center",
      halign = "center",
      forced_height = dpi(18),
      forced_width = dpi(18),
    })
  }

  button:add_button(
    awful.button({}, keys.left_click, nil, instance.stop)
  )

  return button
end

---@param columns Bind[][]
---@return Widget
local function columns_widget(columns)
  local widgets = {}
  for i, column in ipairs(columns) do
    widgets[i] = column_widget(column)
  end

  return margin(dpi(10), {
    widget = wibox.layout.flex.horizontal,
    table.unpack(widgets)
  })
end

local function calculate_columns(width)
  local min_width = 400
  local num_cols = 1
  while (width / num_cols) > min_width do
    num_cols = num_cols + 1
  end

  return num_cols, math.floor(width / num_cols)
end

---@param s awesome.screen
---@param instance Chord
local function generate_popup(instance, s)
  local num_columns, column_width = calculate_columns(s.workarea.width)

  -- Place binds in columns
  local columns = group_binds_into_columns(instance.binds, num_columns)

  -- TODO: Add support for a custom widget between title and columns (injected
  -- in options)

  -- Generate popup widget tree from columns and their binds
  return awful.popup {
    screen = s,
    ontop = true,
    placement = awful.placement.no_offscreen + awful.placement.bottom + awful.placement.maximize_horizontally,
    visible = true,
    bg = beautiful.which_key.bg,
    widget = vertical(
      align_horizontal(
        nil,
        margin(dpi(10), title_widget(instance.title)),
        close_button(instance)
      ),
      columns_widget(columns)
    ),
  }
end

---@return Chord
local function new(instance)
  -- Enter this mode.
  function instance.enter()
    instance.show_popup()
    instance.grabber:start()
  end

  -- Stop this chord.
  function instance.stop()
    instance.hide_popup()
    instance.grabber:stop()
  end

  -- Show the popup without actually entering the mode.
  function instance.show_popup()
    instance.hide_popup()
    local s = awful.screen.focused()
    instance.popup = generate_popup(instance, s)
  end

  function instance.hide_popup()
    if instance.popup ~= nil then
      instance.popup.visible = false
      instance.popup = nil
    end
  end

  return instance
end

-- Create a new which_key chord with a given title. The keygrabber_args
-- will be passed to awful.keygrabber.
-- A chord will exit when a non-sticky key is pressed.
---@return Chord
function which_keys.new_chord(title, keygrabber_args)
  local instance = {}
  local keybindings = {}
  local binds = {}

  for i, binding in ipairs(keygrabber_args.keybindings) do
    local is_sticky = false
    local desc = binding[#binding]
    if type(desc) == "table" then
      is_sticky = desc.which_key_sticky or false
    end

    local decorated_binding = {}
    for j, elem in ipairs(binding) do
      if type(elem) == "function" then
        decorated_binding[j] = function(...)
          if not is_sticky then
            instance.stop()
          end
          return elem(...)
        end
      else
        decorated_binding[j] = elem
      end
    end

    keybindings[i] = decorated_binding
    binds[i] = Bind.new(table.unpack(decorated_binding))
  end

  instance.grabber = awful.keygrabber(
    gears.table.join(
      keygrabber_args,
      {
        keybindings = keybindings,
        timeout_callback = function() instance.hide_popup() end,
        stop_callback = function() instance.hide_popup() end,
        mask_modkeys = true,
        -- Does not work. :(
        -- allowed_keys = {},
        stop_event = "release",
        stop_key = {"Escape"},
      }
    )
  )
  instance.title = title
  instance.binds = binds

  return new(instance)
end

local function split_combo(combo)
  if type(combo) == "table" then
    return combo[1], combo[2]
  end

  local elems = gears.string.split(combo, "+")
  local key = table.remove(elems)

  if aliases_to_keys[key] then
    key = aliases_to_keys[key]
  end

  return elems, key
end

-- Helper method to generate proper keygrabber keybind parameters from
-- something a bit more compact.
--
-- Examples:
--  ("a", "foo", func)
--    -> { {}, "a", func, { description = "foo" } }
--
--  ("Ctrl+b", "bar", func, {baz = true})
--    -> { {"Ctrl"}, "b", func, { description = "bar", baz = true } }
--
--  ("C", "car", func)
--    -> { {"Shift"}, "C", func, { description = "car" } }
--
--  ("D", "dar", func, { which_key_sticky = true })
--    -> { {"Shift"}, "D", func, { description = "@dar", which_key_sticky = true } }
--
function which_keys.key(combo, name, action, overrides)
  local modifiers, key = split_combo(combo)
  local desc = {
    description = name
  }

  -- Auto-detect shifted keys. E.g. when a key is "Ctrl-Q", then render that as
  -- "Ctrl-Q" but register it as {{"Ctrl", "Shift"}, "Q"}.
  -- Don't register characters that are the same in upper/lowercase, like "-".
  if string.len(key) == 1 and string.upper(key) == key and string.lower(key) ~= key then
    desc.which_key_key = desc.which_key_key or combo
    if not gears.table.hasitem(modifiers, "Shift") then
      modifiers = gears.table.join(modifiers, {"Shift"})
    end
    key = string.upper(key)
  end

  if overrides ~= nil then
    desc = gears.table.join(desc, overrides)

    -- Sticky keys should have a "@" in front of their descriptions.
    if overrides.which_key_sticky then
      desc.description = "@" .. desc.description
    end
  end

  return {modifiers, key, action, desc}
end

function which_keys.key_nested(combo, name, keys)
  local modifiers, key = split_combo(combo)
  local chord = which_keys.new_chord(name, {keybindings = keys})

  return {
    modifiers,
    key,
    chord.enter,
    {
      description = "+" .. name,
      which_key_colors = beautiful.which_key.nested
    }
  }
end

return which_keys

