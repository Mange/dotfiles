local luaunit = require("luaunit")

TestClass = require("tests.module.test_class")

os.exit(luaunit.LuaUnit.run())
