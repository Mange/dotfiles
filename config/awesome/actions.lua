local awful = require("awful")
local naughty = require("naughty")

local dropdown = require("dropdown")
local sharedtags = require("sharedtags")
local focus_client = require("focus_client")
local utils = require("utils")

local actions = {}

-- Variables to import
actions.tags = {} -- Assign to table of tags

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

function actions.move_focused_client(offset)
  return function ()
    awful.client.swap.byidx(offset)
  end
end

function actions.spawn(cmdline)
  return function ()
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

function actions.client_toggle_sticky(c)
  c.ontop = not c.ontop
end

function actions.client_toggle_floating(_)
  awful.client.floating.toggle()
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
    local tag = actions.tags[index]

    if not tag then
      tag = sharedtags.add(index, {name = tostring(index), layout = awful.layout.layouts[1]})
    end

    sharedtags.viewonly(tag, tag.screen or awful.screen.focused())
    awful.screen.focus(tag.screen)
  end
end

function actions.toggle_tag(index)
  return function()
    local tag = actions.tags[index]

    if tag then
      sharedtags.viewtoggle(tag, awful.screen.focused())
    end
  end
end

function actions.toggle_client_tag(index)
  return function()
    local tag = actions.tags[index]

    if tag and client.focus then
      client.focus:toggle_tag(tag)
    end
  end
end

function actions.move_to_tag(index)
  return function()
    local tag = actions.tags[index]

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
  return actions.spawn({"rofi", "-modi", "emoji", "-show", "emoji"})
end

function actions.rofi()
  return actions.spawn({
      "rofi",
      "-show", "combi",
      "-modi", "combi,run,window,emoji",
      "-combi-modi", "drun,window,emoji"
    })
end

function actions.select_window()
  return actions.spawn({
      "rofi",
      "-show", "window",
      "-modi", "window,windowcd"
    })
end

function actions.passwords_menu()
  return actions.spawn({"bwmenu", "--clear", "20"})
end

function actions.tydra()
  return actions.spawn({
      "kitty",
      "--class", "dropdown_tydra",
      "zsh", "-ic", "tydra ~/.config/tydra/main.yml"
    })
end

function actions.screenshot(...)
  return actions.spawn({"screenshot", ...})
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
  return actions.spawn({"wmquit", ...})
end

function actions.edit_file(path)
  return actions.spawn({
    "kitty",
    "nvim", path, "+cd %:p:h"
  })
end

function actions.toggle_focus_tag()
  return function()
    focus_client.toggle(client.focus)
  end
end

function actions.volume_change(amount)
  return actions.spawn({"pulsemixer", "--change-volume", amount})
end

function actions.volume_mute_toggle()
  return actions.spawn({"pulsemixer", "--toggle-mute"})
end

function actions.volume_tui()
  return actions.spawn({"kitty", "pulsemixer"})
end

function actions.volume_gui()
  return actions.spawn({"pavucontrol"})
end

return actions
