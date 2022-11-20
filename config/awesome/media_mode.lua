local which_keys = require "module.which_keys_old"
local actions = require "actions"
local wibox = require "wibox"
local utils = require "utils"
local dpi = utils.dpi

local ui_content = nil
if not is_test_mode() then
  ui_content = require "widgets.media-info.content"
end

-- TODO:
--   * Add support for "Next player" / "Previous player"
--     Should pause current player, then switch to the next one in the list of
--     players. Also fetch list of players from playerctl and remove dead
--     players.

local media_mode = which_keys.new_chord("Media", {
  widget_top = wibox.widget {
    widget = wibox.container.margin,
    left = dpi(20),
    top = dpi(20),
    bottom = 0,
    right = dpi(20),
    {
      layout = wibox.layout.fixed.horizontal,
      spacing = dpi(10),
      forced_height = dpi(96),
      ui_content and ui_content.album_cover.widget,
      ui_content and ui_content.song_info.music_info,
    },
  },
  keybindings = {
    -- Playerctl
    which_keys.key(
      "h",
      "previous",
      actions.playerctl_previous(),
      { group = "Player", which_key_sticky = true }
    ),
    which_keys.key(
      "j",
      "play-pause",
      actions.playerctl_play_pause(),
      { group = "Player" }
    ),
    which_keys.key(
      "k",
      "play-pause",
      actions.playerctl_play_pause(),
      { group = "Player" }
    ),
    which_keys.key(
      "l",
      "next",
      actions.playerctl_next(),
      { group = "Player", which_key_sticky = true }
    ),

    -- Volume
    which_keys.key(
      "=",
      "vol +",
      actions.volume_change "+5",
      { group = "Volume", which_key_key = "+", which_key_sticky = true }
    ),
    which_keys.key(
      "-",
      "vol -",
      actions.volume_change "-5",
      { group = "Volume", which_key_sticky = true }
    ),
    which_keys.key(
      "0",
      "toggle-mute",
      actions.volume_mute_toggle(),
      { group = "Volume", which_key_sticky = true }
    ),

    which_keys.key(
      "g",
      "volume-gui",
      actions.volume_gui(),
      { group = "Volume" }
    ),
    which_keys.key(
      "t",
      "volume-tui",
      actions.volume_tui(),
      { group = "Volume" }
    ),
  },
  stop_key = { "Escape", "Enter", "Space", "q" },
})

return media_mode
