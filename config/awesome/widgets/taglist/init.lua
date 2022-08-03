local awful = require "awful"
local wibox = require "wibox"
local beautiful = require "beautiful"

local bling = require "vendor.bling"

local clickable_container = require "widgets.clickable-container"
local keys = require "keys"
local theme = require "theme"
local dpi = beautiful.xresources.apply_dpi

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

local function bling_tag_preview_show(t, s)
  awesome.emit_signal("bling::tag_preview::update", t)
  awesome.emit_signal("bling::tag_preview::visibility", s, true)
end

local function bling_tag_preview_hide(s)
  awesome.emit_signal("bling::tag_preview::visibility", s, false)
end

--- Common method to create buttons.
-- @tab buttons
-- @param object
-- @return table
local function create_buttons(buttons, object)
  if buttons then
    local btns = {}
    for _, b in ipairs(buttons) do
      -- Create a proxy button object: it will receive the real
      -- press and release events, and will propagate them to the
      -- button object the user provided, but with the object as
      -- argument.
      local btn = awful.button {
        modifiers = b.modifiers,
        button = b.button,
        on_press = function()
          b:emit_signal("press", object)
        end,
        on_release = function()
          b:emit_signal("release", object)
        end,
      }
      btns[#btns + 1] = btn
    end
    return btns
  end
end

local function list_update(w, buttons, label, data, objects)
  -- update the widgets, creating them if needed
  w:reset()
  for i, tag in ipairs(objects) do
    local cache = data[tag]
    local ib, tb, bgb, tbm, ibm, l, bg_clickable
    if cache then
      ib = cache.ib
      tb = cache.tb
      bgb = cache.bgb
      tbm = cache.tbm
      ibm = cache.ibm
    else
      ib = wibox.widget.imagebox()
      tb = wibox.widget.textbox()
      bgb = wibox.container.background()
      tbm = wibox.widget {
        tb,
        left = dpi(4),
        right = dpi(16),
        widget = wibox.container.margin,
      }
      ibm = wibox.widget {
        ib,
        margins = dpi(5),
        widget = wibox.container.margin,
      }
      l = wibox.layout.fixed.horizontal()
      bg_clickable = clickable_container({
        widget = wibox.container.margin,
        left = dpi(2),
        right = dpi(2),
        l,
      }, {
        on_mouse_enter = function()
          if #tag:clients() >= 1 then
            bling_tag_preview_show(tag, tag.screen)
          end
        end,
        on_mouse_leave = function()
          bling_tag_preview_hide(tag.screen)
        end,
      })

      -- All of this is added in a fixed widget
      l:fill_space(true)
      l:add(ibm)
      l:add(tbm)

      -- And all of this gets a background
      bgb:set_widget(bg_clickable)

      bgb:buttons(create_buttons(buttons, tag))

      data[tag] = {
        ib = ib,
        tb = tb,
        bgb = bgb,
        tbm = tbm,
        ibm = ibm,
      }
    end

    local text, bg, bg_image, icon, args = label(tag, tb)

    -- Custom text
    text = tag.short_name or text

    args = args or {}

    bgb:set_bg(bg)

    if type(bg_image) == "function" then
      -- TODO: Why does this pass nil as an argument?
      bg_image = bg_image(tb, tag, nil, objects, i)
    end

    bgb:set_bgimage(bg_image)

    if icon then
      local icon_color = tag.icon_color or theme.taglist_fg_normal
      if tag.selected then
        icon_color = tag.selected_icon_color
          or theme.taglist_fg_focus
          or icon_color
      end

      ib.image = gears.color.recolor_image(icon, icon_color)
      tbm:set_margins(0) -- Hide text when showing icon
    else
      -- The text might be invalid, so use pcall.
      if text == nil or text == "" then
        tbm:set_margins(0)
        ibm:set_margins(10) -- No icon and no text, just show empty space
      else
        ibm:set_margins(0) -- Hide icon when showing text
        if not tb:set_markup_silently(text) then
          tb:set_markup "<i>&lt;Invalid text&gt;</i>"
        end
      end
    end

    bgb.shape = args.shape
    bgb.shape_border_width = args.shape_border_width
    bgb.shape_border_color = args.shape_border_color

    w:add(bgb)
  end
end

local taglist = function(s)
  return awful.widget.taglist {
    screen = s,
    filter = awful.widget.taglist.filter.all,
    buttons = awful.util.table.join(
      awful.button({}, keys.left_click, function(t)
        t:view_only()
      end),
      awful.button({ keys.modkey }, keys.left_click, function(t)
        if client.focus then
          client.focus:move_to_tag(t)
          t:view_only()
        end
      end),
      awful.button({}, keys.right_click, awful.tag.viewtoggle),
      awful.button({ keys.modkey }, keys.right_click, function(t)
        if client.focus then
          client.focus:toggle_tag(t)
        end
      end),
      awful.button({}, keys.scroll_up, function(t)
        awful.tag.viewprev(t.screen)
      end),
      awful.button({}, keys.scroll_down, function(t)
        awful.tag.viewnext(t.screen)
      end)
    ),
    style = {},
    update_function = list_update,
    base_widget = wibox.layout.fixed.horizontal(),
  }
end

return taglist
