local awful = require "awful"

return {
  --- @type ModuleInitializerFunction
  initialize = function()
    local old_rules = awful.rules.rules

    --- @module "configuration.client_rules"
    local rules = reload "configuration.client_rules"
    awful.rules.rules = rules

    return function()
      awful.rules.rules = old_rules
    end
  end,
}
