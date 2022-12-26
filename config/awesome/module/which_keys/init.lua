local wibox = require "wibox"
local awful = require "awful"
local gears = require "gears"

local keylib = require "module.keys.lib"
local theme = require "module.theme"
local ui = require "widgets.ui"
local ui_effects = require "widgets.ui.effects"

local M = {}

--- @alias WhichKeyType "menu" | "action"
--- @alias WhichKeyOpts {name: string, keys: table<string, table>}

--- @class WhichKeyItem
--- @field bind KeyBind
--- @field name string
--- @field type WhichKeyType
--- @field action function()

--- @class WhichKeyInstance
--- @field name string
--- @field start function()
--- @field stop function()

--- @param width number
--- @return number
local function calculate_columns(width)
  local min_width = 200
  local max_width = 400

  local columns = math.floor(width / min_width)

  while math.floor(width / columns) > max_width do
    columns = columns + 1
  end

  return columns
end

-- Group a single list of items into multiple lists, column-first, in this
-- fashion:
--
-- [
--  [1, 4, 7],
--  [2, 5, 8],
--  [3, 6]
-- ]
--
-- The number of rows is determined by the number of wanted columns.
local function group_into_columns(items, num_columns)
  -- Determine how many rows are needed. Keep track of the remainder to handle cases like this:
  --
  --  10 items on 4 columns: (2,5 rows, remainder of 2)
  --  A D G I
  --  B E H J
  --  C F
  --
  --  Column indices <= the remainder should use math.ceil(rows) and those
  --  after the remainder should be using math.floor(rows).
  local row_count = #items / num_columns
  local remainder = #items % num_columns

  local columns = {}
  local col_index = 1
  local column = {}

  for i, item in ipairs(items) do
    table.insert(column, item)

    local expected_rows = math.ceil(row_count)
    if col_index > remainder then
      expected_rows = math.floor(row_count)
    end

    -- If we're at the end of the column, or if we're at the end of the list,
    -- insert the column into the list of columns.
    if #column == expected_rows or i == #items then
      table.insert(columns, column)
      column = {}
      col_index = col_index + 1
    end
  end

  --  Another special case is if the number of items is smaller than the number
  --  or columns. In that case some empty columns should also be returned.
  if col_index < num_columns then
    for _ = col_index, num_columns do
      table.insert(columns, {})
    end
  end

  return columns
end

local function render_columns(columns)
  local widgets = {}
  for _, column in ipairs(columns) do
    local column_widget = ui.vertical {
      spacing = theme.spacing(2),
      bg = theme.transparent,
      children = column,
    }

    table.insert(widgets, column_widget)
  end

  return ui.horizontal {
    flex = true,
    spacing = theme.spacing(2),
    children = widgets,
  }
end

local function render_menu(menu, s)
  local num_columns = calculate_columns(s.workarea.width)
  local columns = group_into_columns(menu.item_widgets, num_columns)

  -- Generate popup widget tree from columns and their binds
  menu.popup = awful.popup {
    screen = s,
    ontop = true,
    placement = awful.placement.no_offscreen
      + awful.placement.bottom
      + awful.placement.maximize_horizontally,
    visible = true,
    bg = theme.base,
    widget = ui.vertical {
      children = {
        menu.title_widget,
        render_columns(columns),
      },
    },
  }
end

local function close_menu(menu)
  if menu.popup then
    menu.popup.visible = false
    menu.popup = nil
  end

  if menu.parent_menu then
    menu.parent_menu:start()
  end
end

--- @param bind KeyBind
--- @param opts WhichKeyOpts
local function menu_item(bind, opts, parent)
  local menu = M.create(opts)

  return {
    bind = bind,
    name = menu.name,
    type = "menu",
    menu = menu,
    action = function()
      parent:stop()
      menu:start()
    end,
  }
end

local function action_item(bind, opts, parent)
  local action = opts[1]
  local name = opts[2]

  return {
    bind = bind,
    name = name,
    type = "action",
    action = function()
      parent:stop()
      action()
    end,
  }
end

local function parse_item(key, item, parent)
  local bind = keylib.parse_bind(key)

  if item["name"] then
    -- item is a nested menu
    return menu_item(bind, item, parent)
  else
    return action_item(bind, item, parent)
  end
end

local function parse_items(keys, parent)
  local items = {}

  for key, bind in pairs(keys) do
    table.insert(items, parse_item(key, bind, parent))
  end

  return items
end

--- @param item WhichKeyItem
local function build_item_widget(item)
  local fg = theme.text
  if item.type == "menu" then
    fg = theme.green
  end

  local widget = wibox.widget {
    widget = wibox.container.background,
    bg = theme.transparent,
    fg = fg,
    ui.horizontal {
      spacing = 0,
      children = {
        ui.background {
          bg = theme.surface1,
          fg = theme.text,
          margin = { 0, theme.spacing(1) },
          child = {
            widget = wibox.widget.textbox,
            text = keylib.stringify_bind(item.bind),
            align = "center",
            ellipsize = "start",
            font = theme.font_mono,
          },
        },
        ui.margin(0, theme.spacing(1)) {
          widget = wibox.widget.textbox,
          text = item.name,
          align = "left",
          ellipsize = "end",
          font = theme.font,
        },
      },
    },
  }

  ui_effects.use_clickable(widget, {
    bg = theme.transparent,
    bg_hover = theme.surface1,
    on_left_click = function()
      item.action()
    end,
  })

  return ui.margin(theme.spacing(1), theme.spacing(2))(widget)
end

--- @param items WhichKeyItem[]
local function build_item_widgets(items)
  local widgets = {}

  for _, item in ipairs(items) do
    table.insert(widgets, build_item_widget(item))
  end

  return widgets
end

---@param title string
---@return Widget
local function build_title_widget(title)
  return {
    widget = wibox.container.background,
    fg = theme.rosewater,
    {
      widget = wibox.widget.textbox,
      markup = string.upper(title),
      font = theme.font_size(theme.rm(1.2)),
      align = "center",
    },
  }
end

--- @param items WhichKeyItem[]
local function build_keybindings(items)
  local keybindings = {}

  for _, item in ipairs(items) do
    table.insert(keybindings, {
      item.bind[1],
      item.bind[2],
      item.action,
      { description = item.name },
    })
  end

  return keybindings
end

--- @param opts WhichKeyOpts
--- @return WhichKeyInstance
function M.create(opts)
  local name = opts.name
  local keys = opts.keys

  local instance = {
    name = name,
    title_widget = build_title_widget(name),
  }

  instance.items = parse_items(keys, instance)
  instance.item_widgets = build_item_widgets(instance.items)

  instance.grabber = awful.keygrabber {
    keybindings = build_keybindings(instance.items),
    stop_callback = function()
      close_menu(instance)
    end,
    mask_modkeys = true,
    stop_event = "release",
    stop_key = "Escape",
  }

  function instance.start(self, s)
    self.grabber:start()
    -- TODO: Show after a timeout instead of right away
    render_menu(self, s or awful.screen.focused())
  end

  function instance.stop(self)
    self.grabber:stop()
  end

  return instance
end

return M
