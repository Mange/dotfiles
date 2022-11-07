local spawn = require "awful.spawn"
local timer = require "gears.timer"

local utils = require "utils"

--- @param url string
--- @return string
local function repair_spotify_broken_art_url(url)
  if url then
    local result = string.gsub(
      url,
      "https://open.spotify.com/image/",
      "https://i.scdn.co/image/"
    )
    return result
  else
    return url
  end
end

--- @type string?
local last_art_url = nil

--- @param art_url string?
--- @param func function(string)
local function download_album_art(art_url, func)
  -- Don't download again if last download was the same URL
  if last_art_url == art_url or not art_url then
    return
  end

  last_art_url = art_url

  if art_url and string.len(art_url) > 5 then
    spawn.easy_async({ "coverart-cache", art_url }, function(stdout)
      if stdout then
        local path = utils.strip(stdout)
        if string.len(path) > 10 then
          func(path)
        end
      end
    end)
  end
end

--- @alias PlayerStatus "playing" | "paused" | "stopped"

--- @class PlayerMetadata
--- @field track_id string?
--- @field length string?
--- @field art_url string?
--- @field art_path string?
--- @field album_name string?
--- @field album_artist string?
--- @field artist string?
--- @field auto_rating string?
--- @field disc_number string?
--- @field title string?
--- @field track_number string?
--- @field url string?

--- @class Player
--- @field name string
--- @field status PlayerStatus
--- @field metadata PlayerMetadata

--- @type {[string]: Player}
local players = {}

--- @class Playerctl
local playerctl = {
  ---@type string?
  current_player = nil,
  players = players,
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

-- Since a lot of metadata will update almost at the same time, debounce
-- sending out the event until it has quieted down a bit again.
local metadata_debounce = timer {
  timeout = 0.2,
  call_now = false,
  autostart = false,
  single_shot = true,
  callback = function()
    awesome.emit_signal("mange:playerctl:update", playerctl:current())
  end,
}

--- @param playername string
local function get_player(playername)
  if not players[playername] then
    players[playername] = {
      name = playername,
      status = "stopped",
      metadata = {},
    }
  end
  return players[playername]
end

local function handle_album_art_path(playername, art_url, path)
  local player = get_player(playername)
  -- Only update art_path if the resulting path matches the current art_url.
  -- The metadata could've changed before the album art was downloaded.
  if player.metadata.art_url == art_url then
    player.metadata.art_path = path
    metadata_debounce:again()
  end
end

--- Update metadata for a player
--- @param playername string
--- @param metadata_name string
--- @param value string
local function metadata_set(playername, metadata_name, value)
  local player = get_player(playername)
  local data = player.metadata

  local key = metadata_map[metadata_name] or metadata_name

  if key == "art_url" then
    value = repair_spotify_broken_art_url(value)
    download_album_art(value, function(path)
      handle_album_art_path(playername, value, path)
    end)
  end

  data[key] = value
end

---@param playername string
---@param status PlayerStatus
local function status_set(playername, status)
  local player = get_player(playername)

  local old_status = player.status
  player.status = status

  if playerctl.current_player ~= playername and status == "playing" then
    playerctl.current_player = playername
    awesome.emit_signal("mange:playerctl:update", player)
  elseif old_status ~= status then
    awesome.emit_signal("mange:playerctl:update", player)
  end
end

-- playerctl outputs this each time a metadata key changes:
-- <playername> <metadataname>         <value>
-- There is variable whitespace between metadata name and the value.
--- @param line string
local function handle_metadata_change(line)
  local playername, metadataname, value =
    string.match(line, "(%S+)%s+(%S+)%s+(.+)")

  if playername and metadataname and value then
    metadata_set(playername, metadataname, value)

    -- Since this player just changed, make it the current player
    playerctl.current_player = playername

    metadata_debounce:again()
  end
end

-- playerctl outputs this each time status changes:
-- <playername>	<status>
-- The whitespace is a tab character
--- @param line string
local function handle_status_change(line)
  local playername, status = string.match(line, "([^\t]+)\t([^\t]+)")
  if playername and status then
    status_set(playername, --[[@as string]] status --[[@as PlayerStatus]])
  end
end

local function spawn_status_watcher()
  return spawn.with_line_callback({
    "playerctl",
    "status",
    "--no-messages",
    "--all-players",
    "--follow",
    "--format",
    "{{playerName}}\t{{lc(status)}}",
  }, { stdout = handle_status_change })
end

local function spawn_metadata_watcher()
  return spawn.with_line_callback(
    { "playerctl", "metadata", "--no-messages", "--all-players", "--follow" },
    { stdout = handle_metadata_change }
  )
end

--- @return Player?
function playerctl:current()
  if self.current_player then
    return get_player(self.current_player)
  else
    return nil
  end
end

---@param func fun(player: Player?)
---@return fun() cancel A function to cancel the subscription
function playerctl:on_update(func)
  awesome.connect_signal("mange:playerctl:update", func)
  func(self:current())

  return function()
    awesome.disconnect_signal("mange:playerctl:update", func)
  end
end

---@param command string
local function spawn_playerctl(command)
  ---@type string[]
  local cmdline = { "playerctl" }
  local playername = playerctl.current_player

  if playername then
    table.insert(cmdline, "-p")
    table.insert(cmdline, playername)
  end

  table.insert(cmdline, command)
  spawn(cmdline)
end

function playerctl:play_pause()
  spawn_playerctl "play-pause"
end

function playerctl:previous()
  spawn_playerctl "previous"
end

function playerctl:next()
  spawn_playerctl "next"
end

local function kill(pid)
  -- Negative pid means "Send signal to all processes in this group"
  awesome.kill(-pid, awesome.unix_signal["SIGTERM"])
end

function playerctl.module_initialize()
  local status_pid = spawn_status_watcher()
  local metadata_pid = spawn_metadata_watcher()

  local function cleanup()
    kill(status_pid)
    kill(metadata_pid)
  end

  awesome.connect_signal("exit", cleanup)

  return function()
    cleanup()
    awesome.disconnect_signal("exit", cleanup)
  end
end

return playerctl
