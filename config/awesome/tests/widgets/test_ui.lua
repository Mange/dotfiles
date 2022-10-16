local wibox = require "wibox"
local luaunit = require "luaunit"
local ui = require "widgets.ui"

local tests = {}

function tests:test_margin()
  local child = { widget = "test" }

  local single = ui.margin(4)(child)
  local two = ui.margin(5, 10)(child)
  local three = ui.margin(0, 10, 5)(child)
  local four = ui.margin(1, 2, 3, 4)(child)

  luaunit.assertEquals(single, {
    widget = wibox.container.margin,
    top = 4,
    left = 4,
    bottom = 4,
    right = 4,
    child,
  })

  luaunit.assertEquals(two, {
    widget = wibox.container.margin,
    top = 5,
    left = 10,
    bottom = 5,
    right = 10,
    child,
  })

  luaunit.assertEquals(three, {
    widget = wibox.container.margin,
    top = 0,
    left = 10,
    bottom = 5,
    right = 10,
    child,
  })

  luaunit.assertEquals(four, {
    widget = wibox.container.margin,
    top = 1,
    right = 2,
    bottom = 3,
    left = 4,
    child,
  })
end

return tests
