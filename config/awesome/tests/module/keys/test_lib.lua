local luaunit = require "luaunit"

local keys_lib = require "module.keys.lib"
local tests = {}

function tests:test_parse_bind()
  luaunit.assert_equals(keys_lib.parse_bind "n", { {}, "n" })
  luaunit.assert_equals(keys_lib.parse_bind "mod+n", { { "Mod4" }, "n" })
  luaunit.assert_equals(
    keys_lib.parse_bind "mod+N",
    { { "Mod4", "Shift" }, "n" }
  )
  luaunit.assert_equals(
    keys_lib.parse_bind "mod+shift+n",
    { { "Mod4", "Shift" }, "n" }
  )

  luaunit.assert_equals(keys_lib.parse_bind "CTRL+c", { { "Control" }, "c" })
  luaunit.assert_equals(
    keys_lib.parse_bind "cTRl+C",
    { { "Control", "Shift" }, "c" }
  )
end

function tests:test_parse_bind_aliases()
  luaunit.assert_equals(
    keys_lib.parse_bind "mod+space",
    { { "Mod4" }, "space" }
  )
  luaunit.assert_equals(keys_lib.parse_bind "mod+plus", { { "Mod4" }, "+" })
end

function tests:test_build_awful_keys()
  local dummy = function() end

  luaunit.assert_items_equals(
    keys_lib.build_awful_keys {
      ["mod+n"] = { dummy, "The N" },
      ["mod+shift+n"] = { dummy, "The Cooler N", group = "Cool" },
      ["a"] = { dummy },
    },
    {
      { { "Mod4" }, "n", dummy, { description = "The N" } },
      {
        { "Mod4", "Shift" },
        "n",
        dummy,
        { description = "The Cooler N", group = "Cool" },
      },
      { {}, "a", dummy, {} },
    }
  )
end

function tests:test_build_awful_keys_skips_empty()
  luaunit.assert_items_equals(
    keys_lib.build_awful_keys {
      ["mod+n"] = {},
    },
    {}
  )
end

function tests:test_stringify_binds()
  local function test(input, expected)
    local bind = keys_lib.parse_bind(input)
    luaunit.assert_equals(keys_lib.stringify_bind(bind), expected)
  end

  test("n", "n")
  test("N", "N")
  test("shift+n", "N")

  test("ctrl+shift+x", "C-X")
  test("mod+space", "M-Space")
  test("mod+ctrl+backspace", "M-C-BS")

  test("shift+plus", "S-Plus")
  test("ctrl+shift+-", "C-S-Minus")
end

return tests
