local ui = require "widgets.ui"

local clock = require_module "widgets.bars.clock"

local M = {}

function M.initialize()
  return function()
    cleanup_module "widgets.bars.clock"
  end
end

--- @param s screen
function M.build(s)
  return ui.panel {
    children = {
      clock.build(s),
    },
  }
end

return M
