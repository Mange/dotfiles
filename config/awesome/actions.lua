local awful = require("awful")
local naughty = require("naughty")

local dropdown = require("dropdown")
local sharedtags = require("sharedtags")
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

function actions.client_close(c)
  c:kill()
end

function actions.client_toggle_fullscreen(c)
  c.fullscreen = not c.fullscreen
  c:raise()
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
    local next_screen_idx = (focused_screen.index + 1) % (screen.count() + 1)
    local next_screen = screen[next_screen_idx]

    if tag then
      sharedtags.movetag(tag, next_screen)
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

function actions.screenshot(type)
  return actions.spawn({"screenshot", type})
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

return actions