local wibox = require "wibox"
local spawn = require "awful.spawn"

local ui_content = require "widgets.media-info.content"
local album_cover = ui_content.album_cover
local song_info = ui_content.song_info
local media_buttons = ui_content.media_buttons

local utils = require "utils"
local keys = require "keys"
local actions = require "actions"
local dpi = utils.dpi
local playerctl = require "daemons.playerctl"

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

local current_album_art_url = nil
local function update_album_art(art_url)
  -- Early exit if album art is the same
  if current_album_art_url == art_url then
    return
  end
  current_album_art_url = art_url

  -- Start by switching to generic "no album" art, download the image, and then
  -- switch to the cached copy.
  album_cover.set_default()
  if art_url and string.len(art_url) > 5 then
    spawn.easy_async({ "coverart-cache", art_url }, function(stdout)
      if stdout then
        local path = utils.strip(stdout)
        if string.len(path) > 10 then
          album_cover.set_image(path)
        end
      end
    end)
  end
end

local function update_song_info(status, metadata)
  local title_text = song_info.music_title:get_children_by_id("title")[1]
  local artist_text = song_info.music_artist:get_children_by_id("artist")[1]

  if status == "playing" then
    title_text:set_text(metadata.title or "Untitled media")
    artist_text:set_text(metadata.artist or "No artist")
  else
    title_text:set_text(metadata.title or "Play some media")
    artist_text:set_text(metadata.artist or "")
  end
end

playerctl:on_update(
  ---@diagnostic disable-next-line: unused-local
  function(info)
    update_album_art(info.metadata.art_url)
    update_song_info(info.status, info.metadata)
    media_buttons.update_status(info.status)
  end
)

media_buttons.prev_button:buttons(
  keys.mouse_click({}, keys.left_click, actions.playerctl_previous())
)

media_buttons.play_button:buttons(
  keys.mouse_click({}, keys.left_click, actions.playerctl_play_pause())
)

media_buttons.next_button:buttons(
  keys.mouse_click({}, keys.left_click, actions.playerctl_next())
)

return media_info
