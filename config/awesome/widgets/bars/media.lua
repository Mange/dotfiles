local wibox = require "wibox"

local ui = require "widgets.ui"
local theme = require "module.theme"

local playerctl = require "module.daemons.playerctl"
local media_popup = require "widgets.media_popup"
local player_info = require "widgets.media.player_info"

local M = {
  cleanups_functions = {},
}

local function cleanup_on_reload(func)
  M.cleanups_functions[#M.cleanups_functions + 1] = func
end

--- @param player Player | nil
local function generate_title(player)
  if not player then
    return ""
  end

  local title = player.metadata.title
  local artist = player.metadata.artist or player.metadata.album_artist

  if artist and title then
    return "<b>" .. title .. "</b>\n" .. artist
  elseif title then
    return title
  else
    return ""
  end
end

function M.initialize()
  M.cleanups_functions = {}

  return function()
    for _, cleanup in ipairs(M.cleanups_functions) do
      cleanup()
    end
  end
end

--- @param s screen
function M.build(s)
  local title_widget = wibox.widget {
    widget = wibox.widget.textbox,
    text = "",
    font = theme.font_size(10),
    align = "left",
    valign = "left",
    ellipsize = "end",
  }

  local play_button = wibox.widget {
    widget = wibox.widget.textbox,
    text = "",
    align = "center",
    valign = "center",
  }

  local popup = media_popup.new(s)

  local button
  button = ui.button {
    bg = theme.transparent,
    on_mouse_enter = function()
      popup:show_at(button)
    end,
    on_mouse_leave = function()
      popup:hide()
    end,
    on_left_click = function()
      playerctl:play_pause()
    end,
    child = ui.margin(0, theme.spacing(2)) {
      layout = wibox.layout.fixed.horizontal,
      spacing = theme.spacing(2),
      ui.margin(theme.spacing(4), 0)(player_info.spotify_logo),
      play_button,
      {
        layout = wibox.container.constraint,
        width = theme.spacing(44),
        title_widget,
      },
    },
  }

  --- @param player Player | nil
  local function update(player)
    if player then
      button.visible = true
      local title = generate_title(player)
      title_widget:set_markup(title)

      if player.status == "playing" then
        play_button:set_text ""
      elseif player.status == "paused" then
        play_button:set_text ""
      else
        play_button.set_text " "
      end
    else
      button.visible = false
    end
  end

  update(playerctl:current())
  cleanup_on_reload(playerctl:on_update(update))

  return button
end

return M