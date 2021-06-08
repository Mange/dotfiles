local spawn = require("awful.spawn")
local timer = require("gears.timer")
local utils = require("utils")

local function repair_spotify_broken_art_url(url)
  if url then
    return string.gsub(url, "https://open.spotify.com/image/", "https://i.scdn.co/image/")
  else
    return url
  end
end

-- Index metadata on {player -> {key -> value}}
-- TODO: Implement a LRU cache here to limit to max 3 players at a time…
local all_metadata = {}

-- Index status as {player -> status}
-- TODO: Implement a LRU cache here to limit to max 3 players at a time…
local all_statuses = {}

local playerctl = {
  current_player = nil,
  current_status = nil,
  current_metadata = {},

  metadata = all_metadata,
  statuses = all_statuses,
}

local metadata_map = {
  ["mpris:trackid"] = "track_id",
  ["mpris:length"] = "length",
  ["mpris:artUrl"] = "art_url",
  ["xesam:album"] = "album_name",
  ["xesam:albumArtist"] = "album_artist",
  ["xesam:artist"] = "artist",
  ["xesam:autoRating"] = "auto_rating",
  ["xesam:discNumber"] = "disc_number",
  ["xesam:title"] = "title",
  ["xesam:trackNumber"] = "track_number",
  ["xesam:url"] = "url",
}

local function metadata_get_all(playername)
  local data = all_metadata[playername]
  if (data == nil) then
    data = {}
    all_metadata[playername] = data
  end
  return data
end

-- Update metadata for a player
local function metadata_set(playername, metadata_name, value)
  local data = metadata_get_all(playername)
  local key = metadata_map[metadata_name] or metadata_name
  if key == "art_url" then
    value = repair_spotify_broken_art_url(value)
  end
  data[key] = value
end

local function set_current_player(playername)
  playerctl.current_player = playername
  playerctl.current_status = all_statuses[playername] or "stopped"
  playerctl.current_metadata = metadata_get_all(playername)
end

local function status_set(playername, status)
  local old_status = all_statuses[playername]
  all_statuses[playername] = status

  if playerctl.current_player == playername then
    playerctl.current_status = status
  elseif status == "playing" then
    set_current_player(playername)
  end

  if old_status ~= status then
    awesome.emit_signal("mange:playerctl:update", playerctl:current())
  end
end

-- Since a lot of metadata will update almost at the same time, debounce
-- sending out the event until it has quieted down a bit again.
local metadata_debounce = timer {
  timeout = 0.2,
  call_now = false,
  autostart = false,
  single_shot = true,
  callback = function()
    awesome.emit_signal("mange:playerctl:update", playerctl:current())
  end
}

-- playerctl outputs this each time a metadata key changes:
-- <playername> <metadataname>         <value>
-- There is variable whitespace between metadata name and the value.
local function handle_metadata_change(line)
  local playername, metadataname, value = string.match(line, "(%S+)%s+(%S+)%s+(.+)")
  metadata_set(playername, metadataname, value)
  -- Since this player just changed, make it the current player
  set_current_player(playername)

  metadata_debounce:again()
end

-- playerctl outputs this each time status changes:
-- <playername>	<status>
-- The whitespace is a tab character
local function handle_status_change(line)
  local playername, status = string.match(line, "([^\t]+)\t([^\t]+)")
  status_set(playername, status)
end

local function spawn_status_watcher()
  return spawn.with_line_callback(
    {
      "playerctl", "status",
      "--no-messages", "--all-players",
      "--follow", "--format", "{{playerName}}\t{{lc(status)}}"
    },
    {stdout = handle_status_change}
  )
end

local function spawn_metadata_watcher()
  return spawn.with_line_callback(
    {"playerctl", "metadata", "--no-messages", "--all-players", "--follow"},
    {stdout = handle_metadata_change}
  )
end

function playerctl:current()
  return {
    playername = self.current_player,
    status = self.current_status,
    metadata = self.current_metadata,
  }
end

function playerctl:on_update(func)
  awesome.connect_signal("mange:playerctl:update", func)
end

utils.kill_on_exit(spawn_status_watcher())
utils.kill_on_exit(spawn_metadata_watcher())

return playerctl
