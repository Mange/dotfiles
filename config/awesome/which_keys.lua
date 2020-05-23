--
-- Combine keyboard grabber and a popup menu showing the available bindings.
-- This is trying to replicate Emacs' Hydra/ShowKey / Vim's which-key.
--
-- Used like this:
-- local media_mode = which_keys.new(
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
  color_group = "#d3869b",
  color_bg = "#28282877"
}

local which_keys = {}

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
  local text = fg(style.color_group, "─── " .. group_name .. " ───")

  return wibox.widget {
    widget = wibox.widget.textbox,
    markup = text,
    font = style.font
  }
end

-- Generate textbox widget for a specific keybinding.
--
-- You can set a `which_key_color` inside the keybind's description table and
-- it will be used here instead of the default color.
local function generate_keybind_widget(keybind)
  local modifiers = keybind[1]
  local key = keybind[2]
  local desc = keybind[#keybind]
  local color = desc.which_key_color or style.color_default

  if modifiers and modifiers ~= "none" and #modifiers > 0 then
    key = table.concat(modifiers, "+") .. "+" .. key
  end

  local text = (
    fg(style.color_key, key) .. fg(style.color_arrow, " → ") .. fg(color, desc.description)
  )
  return wibox.widget {
    widget = wibox.widget.textbox,
    markup = text,
    font = style.font
  }
end

-- Generate popup widget for this mode.
local function generate_popup(title, keybindings)
  local grid = wibox.layout.grid.horizontal()

  local grouped_bindings, total_groups = group_binds(keybindings)
  local render_group_names = (total_groups > 1)

  for group_name, group_bindings in pairs(grouped_bindings) do
    local group_grid = wibox.layout.grid.vertical()

    if render_group_names then
      group_grid:add(generate_group_header(group_name))
    end

    for _, bind in ipairs(group_bindings) do
      group_grid:add(generate_keybind_widget(bind))
    end

    grid:add(
      wibox.widget {
        group_grid,
        layout = wibox.container.margin,
        left = style.padding_horizontal,
        top = style.padding_vertical,
        right = style.padding_horizontal,
        bottom = style.padding_vertical
      }
    )
  end

  return awful.popup {
    widget = {
      {
        {
          widget = wibox.widget.textbox,
          markup = fg(style.color_header, title),
          font = style.font_header,
          align = "center"
        },
        grid,
        layout = wibox.layout.fixed.vertical,
      },
      layout = wibox.container.margin,
      left = style.margin,
      top = style.margin,
      right = style.margin,
      bottom = style.margin
    },
    ontop = true,
    placement = awful.placement.no_offscreen + awful.placement.bottom + awful.placement.maximize_horizontally,
    visible = false,
    spacing = 20,
    bg = style.color_bg,
  }
end

-- Create a new which_key mode/layer with a given title. The keygrabber_args
-- will be passed to awful.keygrabber.
function which_keys.new(title, keygrabber_args)
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

  -- Enter this mode.
  function instance.enter()
    instance.show_popup()
    instance.grabber()
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

return which_keys
