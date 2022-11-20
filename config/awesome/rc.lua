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

--
-- Early boot
-- Setting up subsystems, failsafes, etc.
--
require "bootstrap"
require "stdlib"
initialize_module(require "module.patches")
local autostart = require "configuration.autostart"
autostart.early()

--
-- Set up theme variables since other modules will use them
--
if not is_test_mode() then
  local beautiful = require "beautiful"
  beautiful.init(require "theme")
else
  initialize_module(require "module.theme")
end
initialize_module(require "module.wallpaper")
initialize_module(require "module.titlebars")
-- Must be required after theme is set up. Load early otherwise in case other
-- modules want to use some of the functionality.
require "vendor.bling"

--
-- Systems and rules
--
initialize_module(require "module.daemons")
initialize_module(require "module.layout_rotation")
initialize_module(require "module.screens")
initialize_module(require "module.tags")
initialize_module(require "module.keys")
initialize_module(require "module.client_rules")

if not is_test_mode() then
  require "oldrc"
end

--
-- HUD, UI, and widgets
--
if is_test_mode() then
  initialize_module(require "module.hud")
  if not is_awesome_restart() then
    local awful = require "awful"
    awful.spawn.once "wezterm"
  end
end

--
-- Late autostart programs
--
autostart.late()
