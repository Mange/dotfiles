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
local autostart = require "configuration.autostart"

-- Patch some things in AwesomeWM to make it easier to build things.
--- @module "module.patches"
require_module "module.patches"

autostart.early()

if not is_test_mode() then
  require "oldrc"
else
  require_module "module.theme"
end

-- Must be required after theme is set up. Load early otherwise in case other
-- modules want to use some of the functionality.
require "vendor.bling"

require_module "module.layout_rotation"
require_module "module.screens"
require_module "module.tags"
require_module "module.wallpaper"
require_module "module.titlebars"
require_module "module.client_rules"

if is_test_mode() then
  require_module "module.hud"
  if not is_awesome_restart() then
    local awful = require "awful"
    awful.spawn.once "wezterm"
  end
end

autostart.late()
