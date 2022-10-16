local luaunit = require "luaunit"
_G.is_test = true

-- Stub global "awesome" object
require "tests.awesome_stub"

-- Add Awesome environment to load path
package.path = package.path
  .. ";/usr/share/awesome/lib/?.lua;/usr/share/awesome/lib/?/init.lua"

require "stdlib"
TestClass = require "tests.module.test_class"
TestWhichKeysBind = require "tests.module.test_which_keys_bind"
TestNotifcationRules = require "tests.module.test_notification_rules"
TestWidgetsUi = require "tests.widgets.test_ui"
TestUtils = require "tests.test_utils"

os.exit(luaunit.LuaUnit.run())
