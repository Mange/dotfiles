local awful = require "awful"
local gears = require "gears"

local M = {}

--- @param is_reload boolean
function M.module_initialize(is_reload)
  if is_reload then
    reload "configuration.client_rules"
  end

  local rules = require "configuration.client_rules"

  -- Assigning awful.rules.rules seems to be modifying some internal table.
  --
  -- This is not a no-op as one would expect:
  --   x = rules
  --   rules = {}
  --   rules = x
  -- Because `rules = {}` will modify x since it's just some internal
  -- reference.
  --
  -- All of this is important, because Awesome will end up in some sort of
  -- inifinite loop when rules are assigned back to old_rules during the
  -- cleanup.
  local old_rules = gears.table.clone(awful.rules.rules)
  awful.rules.rules = gears.table.clone(rules)

  return function()
    awful.rules.rules = old_rules
  end
end

return M
