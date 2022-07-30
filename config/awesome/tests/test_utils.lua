local luaunit = require "luaunit"
local gears = require "gears"
local utils = require "utils"

local test_class = {}

function test_class:test_uniq()
  luaunit.assert_equals(utils.uniq {}, {})
  luaunit.assert_equals(utils.uniq { 1, 3, 2 }, { 1, 3, 2 })

  -- Input table is not mutated
  local input = { "a", "b", "b", "a" }
  local new = utils.uniq(input)

  luaunit.assert_equals(new, { "a", "b" })
  luaunit.assert_equals(input, { "a", "b", "b", "a" })
end

function test_class:test_async_foreach()
  local list = { "one", "two", "three", "four" }
  local yielded = {}

  utils.async_foreach(list, function(index, item, cont)
    table.insert(yielded, { index, item })
    if index < 3 then
      cont()
    end
  end)

  luaunit.assert_equals(#yielded, 3)
  luaunit.assert_equals(yielded[1], { 1, "one" })
  luaunit.assert_equals(yielded[2], { 2, "two" })
  luaunit.assert_equals(yielded[3], { 3, "three" })
end

return test_class
