local awful = require("awful")

local utils = {}

function utils.run_or_raise(cmd, matchers)
  for _, c in ipairs(client.get()) do
    if c and awful.rules.match(c, matchers) then
      c:jump_to()
      return
    end
  end

  awful.spawn(cmd)
end

return utils
