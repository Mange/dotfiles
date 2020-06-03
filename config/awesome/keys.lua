local gears = require("gears")
local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")

local dropdown = require("dropdown")
local sharedtags = require("sharedtags")

local utils = require("utils")
local which_keys = require("which_keys")
local media_mode = require("media_mode")

-- Settings
local modkey = "Mod4" -- Super
-- Terminal cmdline; note that this is repeated in this file some times because
-- of non-standard CLI arguments, etc.
local terminal = "kitty"

local keys = {}

-- Readable names for mouse buttons
keys.left_click = 1
keys.right_click = 3
keys.scroll_up = 4
keys.scroll_down = 5

-- Export some variables
keys.modkey = modkey

-- Variables to import
keys.tags = {} -- Assign to table of tags

-- Binding actions
-- local function focus(direction)
--   return function()
--     awful.client.focus.global_bydirection(direction)
--   end
-- end

local function focus_idx(offset)
  return function()
    awful.client.focus.byidx(offset)
  end
end

local function quit_menu()
  awesome.spawn { "wmquit" }
end

local function focus_screen(offset)
  return function()
    awful.screen.focus_relative(offset)
  end
end

local function move_focused_idx(offset)
  return function ()
    awful.client.swap.byidx(offset)
  end
end

local function spawn(cmdline)
  return function ()
    awful.spawn(cmdline)
  end
end

local function next_layout()
  awful.layout.inc(1)
end

local function client_close(c)
  c:kill()
end

local function client_toggle_fullscreen(c)
  c.fullscreen = not c.fullscreen
  c:raise()
end

local function client_toggle_sticky(c)
  c.ontop = not c.ontop
end

local function client_toggle_floating(_)
  awful.client.floating.toggle()
end

local function client_move_other_screen(c)
  c:move_to_screen()
end

local function run_or_raise(cmd, matcher)
  return function()
    utils.run_or_raise(cmd, matcher)
  end
end

-- Tag matching client with the currently focused tag, making it appear on the
-- focused screen, then focus it. If already focused, then remove the tag from
-- the window.
local function focus_tag_client(matcher)
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

local function dropdown_toggle(cmd, rule)
  return function()
    dropdown.toggle(cmd, rule)
  end
end

local function goto_tag(index)
  return function()
    local tag = keys.tags[index]

    if not tag then
      tag = sharedtags.add(index, {name = tostring(index), layout = awful.layout.layouts[1]})
    end

    sharedtags.viewonly(tag, tag.screen or awful.screen.focused())
  end
end

local function toggle_tag(index)
  return function()
    local tag = keys.tags[index]

    if tag then
      sharedtags.viewtoggle(tag, awful.screen.focused())
    end
  end
end

local function toggle_client_tag(index)
  return function()
    local tag = keys.tags[index]

    if tag and client.focus then
      client.focus:toggle_tag(tag)
    end
  end
end

local function move_to_tag(index)
  return function()
    local tag = keys.tags[index]

    if tag and client.focus then
      client.focus:move_to_tag(tag)
    end
  end
end

local function tag_move_other_screen()
  local focused_screen = awful.screen.focused()

  local tag = focused_screen.selected_tag
  local next_screen_idx = (focused_screen.index + 1) % (screen.count() + 1)
  local next_screen = screen[next_screen_idx]

  if tag then
    sharedtags.movetag(tag, next_screen)
  end
end

-- Store all binds in a table without their modkey binds, then reuse this for
-- global keys with modkey, and for a Awesome Chord binding triggered.
-- { {mods}, key, … }
local binds = {
    -- Group: Awesome
    {{"Shift"}, "/", hotkeys_popup.show_help, {description="Show keybinds", group="Awesome"}},
    {{}, "z", quit_menu, {description = "Quit", group = "Awesome"}},
    {{"Control"}, "z", awesome.restart, {description = "Restart Awesome", group = "Awesome"}},
    {{"Shift"}, "Escape", spawn("lock-screen"), {description = "Lock screen", group = "Awesome"}},
    {
      {}, "x",
      spawn({"autorandr", "--change", "--default", "horizontal"}),
      {description = "Reflow screens", group = "Awesome"}
    },

    -- Group: Client
    -- {{}, "h", focus("left"), {description = "Focus ←", group = "Client"}},
    -- {{}, "j", focus("down"), {description = "Focus ↓", group = "Client"}},
    -- {{}, "k", focus("up"), {description = "Focus ↑", group = "Client"}},
    -- {{}, "l", focus("right"), {description = "Focus →", group = "Client"}},
    {{}, "j", focus_idx(1), {description = "Focus next", group = "Client"}},
    {{}, "k", focus_idx(-1), {description = "Focus previous", group = "Client"}},
    {{"Shift"}, "j", move_focused_idx(1), {description = "Move next", group = "Client"}},
    {{"Shift"}, "k", move_focused_idx(-1), {description = "Move previous", group = "Client"}},
    {{}, "u", awful.client.urgent.jumpto, {description = "Jump to urgent", group = "Client"}},

    -- Group: Screen
    {{}, "Escape", focus_screen(1), {description = "Next screen", group = "Screen"}},
    {{"Control"}, "l", focus_screen(1), {description = "Next screen", group = "Screen"}},
    {{"Control"}, "h", focus_screen(-1), {description = "Previous screen", group = "Screen"}},

    -- Group: Layout
    {{}, "q", next_layout, {description = "Next layout", group = "Layout"}},

    -- Group: Apps
    {{}, "Return", spawn({"samedir", terminal}), {description = "Terminal in same dir", group = "Apps"}},
    {{"Shift"}, "Return", spawn(terminal), {description = "Terminal", group = "Apps"}},
    {{}, "-", spawn({"screenshot", "full"}), {description = "Screenshot (fullscreen)", group = "Apps"}},
    {{"Shift"}, "-", spawn({"screenshot", "area"}), {description = "Screenshot (area)", group = "Apps"}},
    {{}, "p", spawn({"bwmenu", "--clear", "20"}), {description = "Passwords", group = "Apps"}},

    {{},
      "w",
      run_or_raise(
        {"firefox-developer-edition"},
        {class = "firefoxdeveloperedition"}
        ),
      {description = "Focus browser", group = "Apps"}
    },

    {{"Shift"},
      "w",
      focus_tag_client(
        {class = "firefoxdeveloperedition"}
        ),
      {description = "Focus-tag browser", group = "Apps"}
    },

    {{},
      "e",
      run_or_raise(
        {"samedir", "kitty", "nvim"},
        {class = "kitty", name = "NVIM$"}
        ),
      {description = "Focus editor", group = "Apps"}
    },

    {{"Shift"},
      "e",
      focus_tag_client(
        {class = "kitty", name = "NVIM$"}
        ),
      {description = "Focus-tag editor", group = "Apps"}
    },

    {{},
      "g",
      dropdown_toggle(
        {"kitty", "--class", "dropdown_kitty"},
        {class = "dropdown_kitty"}
        ),
      {description = "Terminal dropdown", group = "Apps"}
    },

    {{"Shift"},
      "g",
      dropdown_toggle(
        {"kitty", "--class", "dropdown_calc", "qalc"},
        {class = "dropdown_calc"}
        ),
      {description = "Calculator dropdown", group = "Apps"}
    },

    {{},
      "t",
      dropdown_toggle(
        {"kitty", "--class", "dropdown_vit", "vit"},
        {class = "dropdown_vit"}
        ),
      {description = "Tasks dropdown", group = "Apps"}
    },

    -- Group: Tag
    {{"Shift"}, "o", tag_move_other_screen, {description = "Move tag to other screen", group = "Tag"}},

    -- Group: Modes
    {{}, "m", media_mode.enter, {description = "Enter media mode", group = "Modes"}},

    --
    -- Vanilla; to be moved and sorted
    --


    -- Layout manipulation
    {{}, "Tab",
      function ()
        awful.client.focus.history.previous()
        if client.focus then
          client.focus:raise()
        end
      end,
    {description = "go back", group = "client"}},

    -- Standard program

    -- {{}, "l",     function () awful.tag.incmwfact( 0.05)          end,
    -- {description = "increase master width factor", group = "layout"}},
    -- {{}, "h",     function () awful.tag.incmwfact(-0.05)          end,
    -- {description = "decrease master width factor", group = "layout"}},
    {{"Shift"}, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
    {description = "increase the number of master clients", group = "layout"}},
    {{"Shift"}, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
    {description = "decrease the number of master clients", group = "layout"}},
    {{"Control"}, "h",     function () awful.tag.incncol( 1, nil, true)    end,
    {description = "increase the number of columns", group = "layout"}},
    {{"Control"}, "l",     function () awful.tag.incncol(-1, nil, true)    end,
    {description = "decrease the number of columns", group = "layout"}},
}

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 10 do
    local key_num = i % 10 -- Turn 10 into 0

    binds = gears.table.join(binds, {
        -- View tag only.
        {{}, tostring(key_num), goto_tag(i), {description = "Go to tag "..i, group = "Tag"}},

        -- Toggle tag display.
        {{"Control"}, tostring(key_num), toggle_tag(i), {description = "Toggle tag "..i, group = "Tag"}},

        -- Move client to tag.
        {{"Shift"}, tostring(key_num), move_to_tag(i), {description = "Move client to tag "..i, group = "Tag"}},

        -- Toggle tag on focused client.
        {{"Control", "Shift"}, tostring(key_num), toggle_client_tag(i), {description = "Toggle client tag "..i, group = "Tag"}}
    })
end

local client_binds = {
    -- Basics
    {{"Shift"}, "q", client_close, {description = "Kill client", group = "Client"}},

    -- Toggles
    {{}, "f", client_toggle_fullscreen, {description = "Fullscreen toggle", group = "Client"}},
    {{"Shift"}, "f", client_toggle_floating, {description = "Floating toggle", group = "Client"}},
    {{"Shift"}, "s", client_toggle_sticky, {description = "Sticky toggle", group = "Client"}},

    -- Screen
    {{}, "o", client_move_other_screen, {description = "Move client to other screen", group = "Client"}},

    --
    -- Vanilla; to be moved and sorted
    --
    {{"Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end, {description = "move to master", group = "client"}}
}

keys.awesome_chord = which_keys.new_chord(
  "Awesome",
  {
    keybindings = gears.table.join(
      binds,
      client_binds,
      -- Binds that should only be for chords
      {
        {{},
          " ",
          spawn({
              "rofi",
              "-show", "combi",
              "-modi", "combi,run,window,emoji",
              "-combi-modi", "drun,window,emoji"
            }),
          {description = "Rofi", group = "Apps"}
        },
        {{"Shift"},
          " ",
          spawn({
              "kitty",
              "--class", "dropdown_tydra",
              "zsh", "-ic", "tydra ~/.config/tydra/main.yml"
            }),
          {description = "Tydra", group = "Apps"}
        }
      }
    ),
    timeout = 5
  }
)

keys.global = gears.table.join(
    -- Binds that should not be part of chord
    awful.key({modkey, "Shift"},
      "space",
      spawn({
          "rofi",
          "-show", "combi",
          "-modi", "combi,run,window,emoji",
          "-combi-modi", "drun,window,emoji"
        }),
      {description = "Rofi", group = "Apps"}
    ),
    awful.key({modkey},
      "space",
      keys.awesome_chord.enter,
      {description = "Chord", group = "Awesome"}
    )
)

for _, bind in ipairs(binds) do
  local mods
  if bind[1] == {} then
    mods = {modkey}
  else
    mods = {modkey, table.unpack(bind[1])}
  end
  keys.global = gears.table.join(keys.global, awful.key(mods, table.unpack(bind, 2)))
end

keys.clientkeys = {}
for _, bind in ipairs(client_binds) do
  local mods
  if bind[1] == {} then
    mods = {modkey}
  else
    mods = {modkey, table.unpack(bind[1])}
  end
  keys.clientkeys = gears.table.join(keys.clientkeys, awful.key(mods, table.unpack(bind, 2)))
end

return keys
