local awful = require "awful"
local gears = require "gears"

local Widgets = require "module.which_keys.widgets"
local Items = require "module.which_keys.items"

local M = {}

--- @alias WhichKeyType "menu" | "action"
--- @alias WhichKeyOpts {name: string, keys: table<string, table>, timeout?: number}

--- @class WhichKeyInstance
--- @field name string
--- @field start function()
--- @field stop function()

local function hide_popup(menu)
  menu.popup_timeout:stop()

  if menu.popup then
    menu.popup.visible = false
    menu.popup = nil
  end
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
  local timeout = opts.timeout or 0.5

  local instance = {
    name = name,
    title_widget = Widgets.build_title_widget(name),
  }

  -- TODO: Get rid of this annoying method?
  -- This is a hack to make the child module Item know how to create menus. We
  -- should perhaps create them lazily by having action implementation moved
  -- into the main module instead?
  function instance.create_child_menu(self, child_opts)
    return M.create(child_opts)
  end

  instance.items = Items.parse_list(keys, instance)
  instance.item_widgets = Widgets.build_item_widgets(instance.items)

  instance.grabber = awful.keygrabber {
    keybindings = build_keybindings(instance.items),
    stop_callback = function()
      hide_popup(instance)
    end,
    mask_modkeys = true,
    stop_event = "release",
    stop_key = "Escape",
  }

  function instance.show_popup(self, s)
    self.popup = Widgets.create_popup(self, s or awful.screen.focused())
  end

  function instance.is_popup_visible(self)
    return self.popup and self.popup.visible or false
  end

  instance.popup_timeout = gears.timer {
    single_shot = true,
    timeout = timeout,
    autostart = false,
    callback = function()
      instance:show_popup()
    end,
  }

  --- @param opts {s?: screen, skip_timeout?: boolean}
  function instance.start(self, opts)
    local skip_timeout = opts and opts.skip_timeout or false
    local s = opts and opts.s

    self.grabber:start()

    if skip_timeout then
      self:show_popup(s)
    else
      self.popup_timeout:start()
    end
  end

  function instance.stop(self)
    self.grabber:stop()
  end

  return instance
end

return M
