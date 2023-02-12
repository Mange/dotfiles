local wibox = require "wibox"
local awful = require "awful"

local keylib = require "module.keys.lib"
local theme = require "module.theme"
local ui = require "widgets.ui"
local ui_effects = require "widgets.ui.effects"

local M = {}

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

function M.create_popup(menu, s)
  local num_columns = calculate_columns(s.workarea.width)
  local columns = group_into_columns(menu.item_widgets, num_columns)

  return awful.popup {
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

--- @param item WhichKeyItem
function M.build_item_widget(item)
  local text_fg = theme.text
  local text_bg = theme.transparent
  local box_fg = theme.text
  local box_bg = theme.surface1

  if item.type == "menu" then
    text_fg = theme.green
    box_fg = theme.mantle
    box_bg = theme.green
  elseif item.sticky then
    text_fg = theme.mauve
    box_fg = theme.mantle
    box_bg = theme.mauve
  end

  local widget = wibox.widget {
    widget = wibox.container.background,
    bg = text_bg,
    fg = text_fg,
    ui.horizontal {
      spacing = 0,
      children = {
        ui.background {
          bg = box_bg,
          fg = box_fg,
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
    bg = text_bg,
    bg_hover = box_bg,
    fg_hover = box_fg,
    on_left_click = function()
      item.action()
    end,
  })

  return ui.margin(theme.spacing(1), theme.spacing(2))(widget)
end

--- @param items WhichKeyItem[]
function M.build_item_widgets(items)
  local widgets = {}

  for _, item in ipairs(items) do
    table.insert(widgets, M.build_item_widget(item))
  end

  return widgets
end

---@param title string
---@return Widget
function M.build_title_widget(title)
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

return M
