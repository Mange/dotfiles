local awful = require "awful"
local wibox = require "wibox"
local beautiful = require "beautiful"
local gears = require "gears"

local bling = require "vendor.bling"

--- @module "module.theme"
local theme = require_module "module.theme"

local ui = require "widgets.ui"
local ui_constants = require "widgets.ui.constants"

--- @module "widgets.ui.effects"
local ui_effects = require_module "widgets.ui.effects"

local M = {}

function M.initialize()
  bling.widget.tag_preview.enable {
    show_client_content = true,
    x = 10,
    y = dpi(48 + 2),
    scale = 0.25, -- The scale of the previews compared to the screen
    honor_padding = false, -- Honor padding when creating widget size
    honor_workarea = false, -- Honor work area when creating widget size
    background_widget = wibox.widget { -- Set a background image (like a wallpaper) for the widget
      image = beautiful.wallpaper,
      horizontal_fit_policy = "fit",
      vertical_fit_policy = "fit",
      widget = wibox.widget.imagebox,
    },
  }

  return function() end
end

local function bling_tag_preview_show(t, s)
  awesome.emit_signal("bling::tag_preview::update", t)
  awesome.emit_signal("bling::tag_preview::visibility", s, true)
end

local function bling_tag_preview_hide(s)
  awesome.emit_signal("bling::tag_preview::visibility", s, false)
end

--- @param t tag | TagConfig
local function tag_number(t)
  return t.number
    or (t.short_name and t.short_name:sub(1, 1))
    or (t.name and t.name:sub(1, 1))
    or "X"
end

--- @param t tag | TagConfig
local function circle_bg(t)
  -- Add 10 for tag number 0, which is actually 10. The rainbow function
  -- rotates.
  return theme.rainbow((t.number or 1) + 10)
end

--- @param self widget
--- @param t TagConfig
local function update_widget(self, t)
  self:get_children_by_id("index_role")[1].text = tag_number(t)
  self:get_children_by_id("circle_background")[1].bg = circle_bg(t)
end

--- @param self widget
--- @param t tag
local function setup_signals(self, t)
  -- Can't add hover effect right now
  ui_effects.use_clickable(self, {
    bg_widget = self:get_children_by_id("circle_background")[1],
    bg = nil,
    bg_hover = theme.overlay1,
    bg_click = nil,
    on_mouse_enter = function()
      if #t:clients() >= 1 then
        bling_tag_preview_show(t, t.screen)
      end
    end,
    on_mouse_leave = function()
      bling_tag_preview_hide(t.screen)
    end,
  })
end

local taglist_buttons = awful.util.table.join(
  -- Left mouse click: View only this tag
  awful.button({}, ui_constants.left_click, function(t)
    t:view_only()
  end),
  -- Super + Left mouse click: Move client to this tag and show only this tag
  awful.button({ ui_constants.modkey }, ui_constants.left_click, function(t)
    if client.focus then
      client.focus:move_to_tag(t)
      t:view_only()
    end
  end),
  -- Right mouse click: Toggle tag
  awful.button({}, ui_constants.right_click, function(t)
    awful.tag.viewtoggle(t)
  end),
  -- Super + Right mouse click: Toggle focused client on tag
  awful.button({ ui_constants.modkey }, ui_constants.right_click, function(t)
    if client.focus then
      client.focus:toggle_tag(t)
    end
  end)
)

--- @param s screen
function M.build(s)
  local tag_list = awful.widget.taglist {
    screen = s,
    filter = awful.widget.taglist.filter.all,
    widget_template = {
      widget = wibox.container.background,
      id = "background_role",
      create_callback = function(self, t)
        update_widget(self, t)
        setup_signals(self, t)
      end,
      update_callback = update_widget,
      ui.margin(2, 2) {
        widget = wibox.container.background,
        shape = gears.shape.circle,
        id = "circle_background",
        bg = theme.rainbow(1),
        fg = theme.mantle,
        {
          widget = wibox.widget.textbox,
          id = "index_role",
          valign = "center",
          halign = "center",
          font = theme.font_bold_size(12),
          forced_width = theme.spacing(6),
          forced_height = theme.spacing(6),
        },
      },
    },
    buttons = taglist_buttons,
  }

  return tag_list
end

return M
