local ui = require "widgets.ui"
local tag_list = require_module "widgets.tag_list"

local M = {}

function M.initialize()
  return function() end
end

--- @param s screen
function M.build(s)
  return ui.panel {
    children = {
      tag_list.build(s),
    },
  }
end

return M
