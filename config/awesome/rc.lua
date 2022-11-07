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
initialize_module(require "module.patches")

autostart.early()

if not is_test_mode() then
  require "oldrc"
else
  initialize_module(require "module.theme")
end

-- Must be required after theme is set up. Load early otherwise in case other
-- modules want to use some of the functionality.
require "vendor.bling"

initialize_module(require "module.daemons")

initialize_module(require "module.layout_rotation")
initialize_module(require "module.screens")
initialize_module(require "module.tags")
initialize_module(require "module.wallpaper")
initialize_module(require "module.titlebars")
initialize_module(require "module.client_rules")

if is_test_mode() then
  initialize_module(require "module.hud")
  if not is_awesome_restart() then
    local awful = require "awful"
    awful.spawn.once "wezterm"
  end
end

autostart.late()
