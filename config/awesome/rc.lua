--      ██
--     ████
--    ██░░██   ███     ██  █████   ██████  ██████  ██████████   █████
--   ██  ░░██ ░░██  █ ░██ ██░░░██ ██░░░░  ██░░░░██░░██░░██░░██ ██░░░██
--  ██████████ ░██ ███░██░███████░░█████ ░██   ░██ ░██ ░██ ░██░███████
-- ░██░░░░░░██ ░████░████░██░░░░  ░░░░░██░██   ░██ ░██ ░██ ░██░██░░░░
-- ░██     ░██ ███░ ░░░██░░██████ ██████ ░░██████  ███ ░██ ░██░░██████
-- ░░      ░░ ░░░    ░░░  ░░░░░░ ░░░░░░   ░░░░░░  ░░░  ░░  ░░  ░░░░░░
--  ██       ██ ████     ████
-- ░██      ░██░██░██   ██░██
-- ░██   █  ░██░██░░██ ██ ░██
-- ░██  ███ ░██░██ ░░███  ░██
-- ░██ ██░██░██░██  ░░█   ░██
-- ░████ ░░████░██   ░    ░██
-- ░██░   ░░░██░██        ░██
-- ░░       ░░ ░░         ░░
--

require "bootstrap"
require "stdlib"

-- Patch some things in AwesomeWM to make it easier to build things.
--- @module "module.patches"
require_module "module.patches"

local autostart = require "configuration.autostart"
autostart.early()

if not is_test_mode() then
  require "oldrc"
else
  --- @module "configuration.theme"
  require_module "configuration.theme"
end

--- @module "configuration.client_rules"
require_module "configuration.client_rules"

--- @module "module.titlebars"
require_module "module.titlebars"
require "vendor.bling"

autostart.late()
