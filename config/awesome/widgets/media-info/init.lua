local wibox = require "wibox"

local ui_content = require "widgets.media-info.content"
local album_cover = ui_content.album_cover
local song_info = ui_content.song_info
local media_buttons = ui_content.media_buttons

local utils = require "utils"
local keys = require "keys"
local actions = require "actions"
local dpi = utils.dpi

local playerctl = require "module.daemons.playerctl"

local media_info = wibox.widget {
  layout = wibox.layout.align.horizontal,
  {
    layout = wibox.layout.fixed.horizontal,
    spacing = dpi(10),
    album_cover.widget,
    song_info.music_info,
  },
  nil,
  {
    layout = wibox.layout.align.vertical,
    expand = "none",
    nil,
    media_buttons.navigate_buttons,
    nil,
  },
}

--- @param path string?
local function update_album_art(path)
  if path then
    album_cover.set_image(path)
  else
    album_cover.set_default()
  end
end

---@param player Player
local function update_song_info(player)
  local title_text = song_info.music_title:get_children_by_id("title")[1]
  local artist_text = song_info.music_artist:get_children_by_id("artist")[1]

  if not player then
    title_text:set_text "Play some media"
    artist_text:set_text ""
  elseif player.status == "playing" then
    title_text:set_text(player.metadata.title or "Untitled media")
    artist_text:set_text(player.metadata.artist or "No artist")
  else
    title_text:set_text(player.metadata.title or "Play some media")
    artist_text:set_text(player.metadata.artist or "")
  end
end

playerctl:on_update(function(player)
  if player then
    update_album_art(player.metadata.art_path)
    update_song_info(player)
    media_buttons.update_status(player.status)
  else
    update_album_art(nil)
    update_song_info(player)
    media_buttons.update_status "stopped"
  end
end)

media_buttons.prev_button:buttons(
  keys.mouse_click({}, keys.left_click, actions.playerctl_previous())
)

media_buttons.play_button:buttons(
  keys.mouse_click({}, keys.left_click, actions.playerctl_play_pause())
)

media_buttons.next_button:buttons(
  keys.mouse_click({}, keys.left_click, actions.playerctl_next())
)

return { widget = media_info }
