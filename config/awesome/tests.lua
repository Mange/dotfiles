local luaunit = require("luaunit")

TestClass = require("tests.module.test_class")
TestWhichKeysBind = require("tests.module.test_which_keys_bind")

os.exit(luaunit.LuaUnit.run())
