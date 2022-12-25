local luaunit = require "luaunit"

local tests = {}

function tests:test_round()
  luaunit.assert_equals(round(1), 1)
  luaunit.assert_equals(round(0), 0)
  luaunit.assert_equals(round(-1), -1)

  luaunit.assert_equals(round(1.5), 2)
  luaunit.assert_equals(round(1.4), 1)
  luaunit.assert_equals(round(-1.5), -2)
  luaunit.assert_equals(round(-1.4), -1)
end

return tests
