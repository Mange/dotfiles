local awful = require "awful"
local naughty = require "naughty"
local bling = require "vendor.bling"
local unpack = unpack or table.unpack

local dropdown = require "dropdown"
local sharedtags = require "sharedtags"
local focus_client = require "focus_client"
local utils = require "utils"

--- @module "module.tags"
local tags = require_module("module.tags").tags

--- @module "module.daemons.playerctl"
local playerctl = require_module "module.daemons.playerctl"

local brightness = require "module.daemons.brightness"

local actions = {}

local function ensure_all_functions(...)
  local funcs = {}

  for i, fn in ipairs { ... } do
    if type(fn) ~= "function" then
      error("Argument " .. i .. " is not a function, is " .. tostring(fn))
    end
    funcs[#funcs + 1] = fn
  end

  return funcs
end

function actions.compose(...)
  local funcs = ensure_all_functions(...)
  return function(...)
    local result = { ... }
    for _, fn in ipairs(funcs) do
      result = { fn(unpack(result)) }
    end
    return result
  end
end

local function focus_on_index(current_index, target_index)
  return awful.client.focus.byidx(target_index - current_index)
end

local function focus_direction(direction, c)
  awful.client.focus.global_bydirection(direction, c, true)
end

-- When layout is mstab, then direction should mean something else:
-- left = go to master
-- right = to to slaves
local function focus_mstab(direction, c, t)
  if not utils.is_master(c) then
    -- focus is inside the tablist
    local my_index = utils.client_index(c)
    local total_clients = #c.screen.clients
    local master_clients = t.master_count

    if direction == "left" then
      -- Move to last master.
      return focus_on_index(my_index, master_clients)
    elseif direction == "down" then
      -- Focus next slave, wrapping around without getting to the first master again.
      if my_index == total_clients then
        return focus_on_index(my_index, master_clients + 1)
      else
        return awful.client.focus.byidx(1)
      end
    elseif direction == "up" then
      -- Focus previous slave, wrapping around without getting to the last master again.
      if my_index == master_clients + 1 then
        return focus_on_index(my_index, total_clients)
      else
        return awful.client.focus.byidx(-1)
      end
    end
  end

  -- Eh, just use default behavior…
  return focus_direction(direction, c)
end

local function focus_max(direction, c)
  -- Fullscreen windows means that I usually use "down/up" for next/right and
  -- keep left/right for next/previous screen.
  if direction == "down" then
    return awful.client.focus.byidx(1)
  elseif direction == "up" then
    return awful.client.focus.byidx(-1)
  else
    focus_direction(direction, c)
  end
end

function actions.focus(direction)
  return function()
    local c = client.focus
    if c then
      -- No matter which layout that is in use on the screen, if the client
      -- itself is floating then go by direction.
      if c.floating then
        return focus_direction(direction, c)
      end

      local tag = c.screen.selected_tag
      if tag.layout == bling.layout.mstab then
        focus_mstab(direction, c, tag)
      elseif
        tag.layout == awful.layout.suit.max
        or tag.layout == awful.layout.suit.max.fullscreen
      then
        focus_max(direction, c)
      else
        focus_direction(direction, c)
      end
    else
      -- No client? Maybe we closed the last one on the screen…?
      focus_direction(direction, nil)
    end
  end
end

function actions.focus_by_index(offset)
  return function()
    awful.client.focus.byidx(offset)
  end
end

function actions.focus_screen(offset)
  return function()
    awful.screen.focus_relative(offset)
  end
end

function actions.focus_screen_dir(direction)
  return function()
    awful.screen.focus_bydirection(direction)
  end
end

function actions.move_focused_client(offset)
  return function()
    awful.client.swap.byidx(offset)
  end
end

---@param cmdline string[] | string
function actions.spawn(cmdline)
  return function()
    awful.spawn(cmdline)
  end
end

function actions.next_layout()
  return function()
    awful.layout.inc(1)
  end
end

function actions.previous_layout()
  return function()
    awful.layout.inc(-1)
  end
end

function actions.set_layout(layout)
  return function()
    awful.layout.set(layout)
  end
end

function actions.on_focused_client(action, ...)
  local extra = table.pack(...)
  return function()
    if client.focus then
      action(client.focus, unpack(extra))
    end
  end
end

function actions.client_close(c)
  c:kill()
end

function actions.client_toggle_fullscreen(c)
  c.fullscreen = not c.fullscreen
  c:raise()
end

function actions.client_minimize(c)
  c.minimized = true
end

function actions.client_restore(c)
  c.maximized = false
  c.maximized_vertical = false
  c.maximized_horizontal = false
  c.minimized = false
  c.ontop = false
  c.fullscreen = false
end

function actions.client_toggle_ontop(c)
  c.ontop = not c.ontop
end

function actions.client_toggle_sticky(c)
  c.sticky = not c.sticky
end

function actions.client_toggle_floating(_)
  awful.client.floating.toggle()
end

function actions.client_set_titlebar(c, show)
  if show then
    awful.titlebar.show(c)
  else
    awful.titlebar.hide(c)
  end
end

function actions.client_toggle_titlebar(c)
  awful.titlebar.toggle(c)
end

function actions.client_move_other_screen(c)
  c:move_to_screen()
end

-- Minimized clients cannot be focused, so not possible to bind a key to
-- unminimize that particular client.
-- Workaround to target specific window: `select_window` action.
function actions.unminimize_random()
  return function()
    local c = awful.client.restore()
    if c then
      client.focus = c
      c:raise()
    end
  end
end

function actions.run_or_raise(cmd, matcher)
  return function()
    utils.run_or_raise(cmd, matcher)
  end
end

-- Tag matching client with the currently focused tag, making it appear on the
-- focused screen, then focus it. If already focused, then remove the tag from
-- the window.
function actions.focus_tag_client(matcher)
  return function()
    local c = utils.find_client(matcher)
    local t = awful.screen.focused().selected_tag

    if not t or not c then
      return
    end

    if utils.client_has_tag(c, t) then
      if client.focus == c then
        -- If tagged and has focus already, then remove the tag
        c:toggle_tag(t)
        awful.client.focus.history.previous()
      else
        -- Tagged, but not focused; behave like normal jump_to
        c:jump_to()
      end
    else
      -- Not already tagged; add the tag and jump to it
      c:toggle_tag(t)
      c:jump_to()
    end
  end
end

function actions.dropdown_toggle(cmd, rule)
  return function()
    dropdown.toggle(cmd, rule)
  end
end

function actions.goto_tag(index)
  return function()
    local tag = tags[index]

    if not tag then
      tag = sharedtags.add(
        index,
        { name = tostring(index), layout = awful.layout.layouts[1] }
      )
    end

    sharedtags.viewonly(tag, tag.screen or awful.screen.focused())
    awful.screen.focus(tag.screen)
  end
end

function actions.toggle_tag(index)
  return function()
    local tag = tags[index]

    if tag then
      sharedtags.viewtoggle(tag, awful.screen.focused())
    end
  end
end

function actions.toggle_client_tag(index)
  return function()
    local tag = tags[index]

    if tag and client.focus then
      client.focus:toggle_tag(tag)
    end
  end
end

function actions.move_to_tag(index)
  return function()
    local tag = tags[index]

    if tag and client.focus then
      client.focus:move_to_tag(tag)
    end
  end
end

function actions.tag_move_other_screen()
  return function()
    local focused_screen = awful.screen.focused()

    local tag = focused_screen.selected_tag
    -- Lua index on 1, so we want a "-1" to go back to 0-based indexing for
    -- the modulus math to work properly.
    -- Then we "+1" to say "Next". "-1+1" is just redundant, so use the current
    -- 1-based index to mean "next" in a 0-based index.
    -- Then finally, convert back to 1-based indexing by adding one after the
    -- modulus math is over.
    --
    -- (1 % 2) + 1 = 2
    -- (2 % 2) + 1 = 1
    local next_screen_idx = (focused_screen.index % screen.count()) + 1
    local next_screen = screen[next_screen_idx]

    if tag then
      sharedtags.movetag(tag, next_screen)
      sharedtags.viewonly(tag, next_screen)
      awful.screen.focus(next_screen)
    end
  end
end

function actions.emoji_selector()
  return actions.spawn { "rofi", "-modi", "emoji", "-show", "emoji" }
end

function actions.rofi()
  return actions.spawn {
    "rofi",
    "-show",
    "combi",
    "-modi",
    "combi,run,window",
    "-combi-modi",
    "drun,window",
  }
end

function actions.select_window()
  return actions.spawn {
    "rofi",
    "-show",
    "window",
    "-modi",
    "window,windowcd",
  }
end

function actions.passwords_menu()
  return actions.spawn { "bwmenu", "--clear", "20" }
end

function actions.flameshot(...)
  return actions.spawn { "flameshot", ... }
end

function actions.dismiss_notification()
  -- Dismiss the first nofification that we are able to find
  local reason = naughty.notificationClosedReason.dismissedByUser
  return function()
    local s = awful.screen.focused()
    local notifications = naughty.notifications[s]
    if notifications then
      for pos in pairs(notifications) do
        if notifications[pos][1] then
          naughty.destroy(notifications[pos][1], reason)
          return
        end
      end
    end
  end
end

function actions.dismiss_all_notifications()
  local reason = naughty.notificationClosedReason.dismissedByUser
  return function()
    naughty.destroy_all_notifications(nil, reason)
  end
end

function actions.log_out(...)
  return actions.spawn { "wmquit", ... }
end

function actions.edit_file(path)
  local dir, file = utils.path_split(path)
  local args = {
    "wezterm",
    "start",
  }

  if dir ~= nil then
    table.insert(args, "--cwd")
    table.insert(args, dir)
  end

  table.insert(args, "--")
  table.insert(args, "nvim")
  table.insert(args, file)

  return actions.spawn(args)
end

function actions.toggle_focus_tag()
  return function()
    focus_client.toggle(client.focus)
  end
end

function actions.toggle_calendar_popup()
  return function()
    local popup = awful.screen.focused().month_calendar
    if popup then
      popup:toggle()
    end
  end
end

function actions.toggle_control_center()
  return function()
    local center = awful.screen.focused().control_center
    if center then
      center:toggle()
    end
  end
end

function actions.close_control_center()
  return function()
    local center = awful.screen.focused().control_center
    if center then
      center:close()
    end
  end
end

function actions.toggle_systray()
  return function()
    awesome.emit_signal "widget::systray:toggle"
  end
end

function actions.volume_set(percent)
  return actions.spawn { "pulsemixer", "--set-volume", tostring(percent) }
end

function actions.volume_set_now(percent)
  actions.volume_set(percent)()
end

function actions.volume_change(amount)
  return actions.spawn { "pulsemixer", "--change-volume", amount }
end

function actions.volume_mute_toggle()
  return actions.spawn { "pulsemixer", "--toggle-mute" }
end

function actions.volume_tui()
  return actions.spawn { "wezterm", "start", "--", "pulsemixer" }
end

function actions.volume_gui()
  return actions.spawn { "pavucontrol" }
end

function actions.playerctl_play_pause()
  return function()
    playerctl:play_pause()
  end
end

function actions.playerctl_previous()
  return function()
    playerctl:previous()
  end
end

function actions.playerctl_next()
  return function()
    playerctl:next()
  end
end

function actions.brightness_change(amount)
  return function()
    brightness:set(amount)
  end
end

return actions
