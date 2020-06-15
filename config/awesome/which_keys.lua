--
-- Combine keyboard grabber and a popup menu showing the available bindings.
-- This is trying to replicate Emacs' Hydra/ShowKey / Vim's which-key.
--
-- Used like this:
-- local media_mode = which_keys.new_mode(
--   "My mode",
--   {
--    keybindings = {
--      {{}, "k", playerctl("play-pause"), {description = "Play/pause", group = "Player"}}
--    },
--    stop_key = ["Escape"],
--    timeout = 5,
--  }
-- )
-- media_mode.enter()
--
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
--

local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

local style = {
  font_header = "Fira Sans Regular 18",
  font = "Fira Sans Regular 14",
  padding_horizontal = 10,
  padding_vertical = 5,
  margin = 20,
  color_header = "#83a598",
  color_default = "#83a598",
  color_arrow = "#79740e",
  color_key = "#79740e",
  color_nested = "#cc241d",
  color_group = "#d3869b",
  color_bg = "#28282877"
}

local aliases = {
  [" "] = "Space"
}

local aliases_to_keys = {
  Space = " ",
  space = " "
}

local which_keys = {
  color_normal = style.color_key,
  color_nested = style.color_nested,
}

-- Generate pango markup to change foreground color for the given text.
local function fg(color, text)
  return "<span foreground=\"" .. tostring(color) .. "\">" .. tostring(text) .. "</span>"
end

-- Group the passed table of binds into a
--
--    {"Group name" -> {binding1, binding2, …}}
--
-- table.
local function group_binds(keybindings)
  local total = 0
  local groups = {}

  for _, binding in ipairs(keybindings) do
    local desc = binding[#binding]
    local group_name = desc.group or "Misc"
    local group = groups[group_name]

    if group == nil then
      group = {}
      groups[group_name] = group
      total = total + 1
    end

    table.insert(group, binding)
  end

  return groups, total
end

-- Generate textbox widget for a group header.
local function generate_group_header(group_name)
  local text = fg(style.color_group, group_name)

  return wibox.widget {
    widget = wibox.container.background,
    bg = style.color_group .. "22",
    {
      widget = wibox.widget.textbox,
      markup = text,
      font = style.font
    }
  }
end

-- Generate textbox widget for a specific keybinding.
--
-- You can set a `which_key_color` inside the keybind's description table and
-- it will be used here instead of the default color.
local function generate_keybind_widget(keybind, forced_width)
  local modifiers = keybind[1]
  local key = keybind[2]
  local desc = keybind[#keybind]
  local color = desc.which_key_color or style.color_default

  -- Support hiding keys from description
  if desc.which_key_hidden then
    return nil
  end

  -- Fix some aliases
  if aliases[key] ~= nil then
    key = aliases[key]
  end

  -- Add modifiers to key combo, if set
  if modifiers and modifiers ~= "none" and #modifiers > 0 then
    key = table.concat(modifiers, "+") .. "+" .. key
  end

  -- Support overriding the apparent shortcut key
  if desc.which_key_key ~= nil then
    key = desc.which_key_key
  end

  local w = wibox.widget {
    widget = wibox.layout.ratio.horizontal,
    forced_width = forced_width,
    inner_fill_strategy = "center",
    {
      widget = wibox.widget.textbox,
      markup = fg(style.color_key, key),
      align = "right",
      font = style.font
    },
    {
      widget = wibox.widget.textbox,
      markup = fg(style.color_arrow, " → "),
      align = "center",
      font = style.font
    },
    {
      widget = wibox.widget.textbox,
      markup = fg(color, desc.description),
      align = "left",
      font = style.font
    },
  }
  w:ajust_ratio(2, 0.40, 0.1, 0.50)

  return w
end

local function generate_popup(title, keybindings)
  local grouped_bindings, total_groups = group_binds(keybindings)

  -- Place all widgets here grouped by the group name.
  local key_widgets = {}
  local key_width = 200 -- TODO: Decide this more intelligently

  -- Generate individual key widgets
  for group_name, group_bindings in pairs(grouped_bindings) do
    for _, bind in ipairs(group_bindings) do
      if key_widgets[group_name] == nil then
        key_widgets[group_name] = {}
      end

      local w = generate_keybind_widget(bind, key_width)
      if w ~= nil then
        table.insert(key_widgets[group_name], w)
      end
    end
  end

  -- Calculate how many columns should be used
  -- TODO: This needs to happen on a per-screen basis.
  local number_of_columns = 6 -- TODO: Calculate using key_width and screen's dimensions

  -- Create widget and add all the groups to it
  local popup_widget = wibox.layout.flex.vertical()
  popup_widget.spacing = style.padding_vertical
  if title ~= nil then
    popup_widget:add(wibox.widget {
      widget = wibox.widget.textbox,
      markup = fg(style.color_header, title),
      font = style.font_header,
      align = "center"
    })
  end

  for group_name, widgets in pairs(key_widgets) do
    -- Only render group names when there are more than a single group
    if total_groups > 1 then
      popup_widget:add(generate_group_header(group_name))
    end

    -- Insert grid of all keys
    local grid = wibox.layout.grid.vertical(number_of_columns)
    grid.expand = true
    grid.homogeneous = true
    grid.spacing = 5
    for _, w in ipairs(widgets) do
      grid:add(w)
    end

    popup_widget:add(grid)
  end

  return awful.popup {
    widget = {
      widget = wibox.container.margin,
      margins = style.margin,
      popup_widget
    },
    ontop = true,
    placement = awful.placement.no_offscreen + awful.placement.bottom + awful.placement.maximize_horizontally,
    visible = false,
    spacing = 20,
    bg = style.color_bg,
  }
end

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
    instance.popup.visible = true
  end

  -- Hide the popup if visible.
  function instance.hide_popup()
    instance.popup.visible = false
  end

  return instance
end

-- Create a new which_key mode/layer with a given title. The keygrabber_args
-- will be passed to awful.keygrabber.
-- A mode will be active until Escape is pressed.
function which_keys.new_mode(title, keygrabber_args)
  local instance
  instance = {
    grabber = awful.keygrabber(
      gears.table.join(
        keygrabber_args,
        {
          stop_callback = function() instance.hide_popup() end,
        }
      )
    ),
    popup = generate_popup(title, keygrabber_args.keybindings)
  }

  return new(instance)
end

-- Create a new which_key chord with a given title. The keygrabber_args
-- will be passed to awful.keygrabber.
-- A chord will exit on the first keypress.
function which_keys.new_chord(title, keygrabber_args)
  local instance = {}
  local keybindings = {}

  for i, binding in ipairs(keygrabber_args.keybindings) do
    local decorated_binding = {}
    -- TODO: Modify the action function to call the original function, then stop the key grabber.
    for j, elem in ipairs(binding) do
      if type(elem) == "function" then
        decorated_binding[j] = function(...)
          instance.stop()
          return elem(...)
        end
      else
        decorated_binding[j] = elem
      end
    end

    keybindings[i] = decorated_binding
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
  instance.popup = generate_popup(title, keygrabber_args.keybindings)

  return new(instance)
end

local function split_combo(combo)
  local elems = gears.string.split(combo, "+")
  local key = table.remove(elems)

  if aliases_to_keys[key] then
    key = aliases_to_keys[key]
  end

  return elems, key
end

function which_keys.key(combo, name, action)
  local modifiers, key = split_combo(combo)

  return {modifiers, key, action, {description = name}}
end

function which_keys.key_nested(combo, name, keys)
  local modifiers, key = split_combo(combo)
  local chord = which_keys.new_chord(name, {keybindings = keys})

  return {
    modifiers, key,
    chord.enter,
    {
      description = "+" .. name,
      which_key_color = which_keys.color_nested
    }
  }
end

return which_keys
