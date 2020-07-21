local awful = require("awful")

local utils = require("utils")

local dropdown = {}

function dropdown.add_rules(rules)
  table.insert(
    rules,
    {
      rule_any = {class = {"dropdown_"}},
      properties = {
        floating = true,
        placement = utils.placement_centered(0.5),
      }
    }
  )
end

local function raise(c)
  -- Move to current screen and put on tags that are currently selected
  local s = awful.screen.focused()
  c:move_to_screen(s)
  c:tags(s.selected_tags)
  c:jump_to()
end

local function hide(c)
  -- Remove screen tags from the client
  local current_tags = c:tags()
  local screen_tags = c.screen.tags
  local new_tags = {}

  for _, t in ipairs(current_tags) do
    local on_screen = false
    for _, st in ipairs(screen_tags) do
      if t == st then
        on_screen = true
        break
      end
    end
    if not on_screen then
      table.insert(new_tags, t)
    end
  end

  c:tags(new_tags)
  c:lower()
end

function dropdown.raise(cmd, rule)
  for _, c in ipairs(client.get()) do
    if c and awful.rules.match(c, rule) then
      raise(c)
      return
    end
  end

  awful.spawn(cmd)
end

function dropdown.toggle(cmd, rule)
  if client.focus and awful.rules.match(client.focus, rule) then
    hide(client.focus)
  else
    dropdown.raise(cmd, rule)
  end
end

return dropdown
