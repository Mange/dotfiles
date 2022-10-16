local ui = require "widgets.ui"

local M = {}

function M.initialize()
  return function() end
end

function M.build()
  return ui.panel {
    children = {
      ui.placeholder("#220000", "state"),
    },
  }
end

return M
