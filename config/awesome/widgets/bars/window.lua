local ui = require "widgets.ui"

local M = {}

function M.initialize()
  return function() end
end

function M.build()
  return ui.panel {
    children = {
      ui.placeholder("#000022", "window"),
    },
  }
end

return M
