local awful = require "awful"

local Widgets = require "module.which_keys.widgets"
local Items = require "module.which_keys.items"

local M = {}

--- @alias WhichKeyType "menu" | "action"
--- @alias WhichKeyOpts {name: string, keys: table<string, table>}

--- @class WhichKeyInstance
--- @field name string
--- @field start function()
--- @field stop function()

local function hide_popup(menu)
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

  function instance.start(self, s)
    self.grabber:start()
    -- TODO: Show after a timeout instead of right away
    instance.popup = Widgets.create_popup(self, s or awful.screen.focused())
  end

  function instance.stop(self)
    self.grabber:stop()
  end

  return instance
end

return M
