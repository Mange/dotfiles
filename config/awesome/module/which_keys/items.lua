local keylib = require "module.keys.lib"

--- @class WhichKeyItem
--- @field bind KeyBind
--- @field name string
--- @field type WhichKeyType
--- @field sticky boolean
--- @field action function()

local M = {}

--- @param bind KeyBind
--- @param opts WhichKeyOpts
local function menu_item(bind, opts, menu)
  local child_menu = menu:create_child_menu(opts)

  return {
    bind = bind,
    name = "+" .. menu.name,
    type = "menu",
    menu = child_menu,
    action = function()
      local popup_visible = menu:is_popup_visible()

      menu:stop()
      child_menu:start { skip_timeout = popup_visible }
    end,
  }
end

local function action_item(bind, opts, menu)
  local action = opts[1]
  local name = opts[2]
  local sticky = opts.sticky or false

  local label = name
  if sticky then
    label = "@" .. label
  end

  return {
    bind = bind,
    name = label,
    type = "action",
    sticky = sticky,
    action = function()
      if sticky then
        if menu.popup_timeout.started then
          menu.popup_timeout:again()
        end
      else
        menu:stop()
      end
      action()
    end,
  }
end

function M.parse(key, item, menu)
  local bind = keylib.parse_bind(key)

  if item["name"] then
    -- item is a nested menu
    return menu_item(bind, item, menu)
  else
    return action_item(bind, item, menu)
  end
end

function M.parse_list(keys, menu)
  local items = {}

  for key, bind in pairs(keys) do
    table.insert(items, M.parse(key, bind, menu))
  end

  return items
end

return M
