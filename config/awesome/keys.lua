local gears = require("gears")
local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")

local actions = require("actions")
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

-- Binding actions
-- local function focus(direction)
--   return function()
--     awful.client.focus.global_bydirection(direction)
--   end
-- end

-- Store all binds in a table without their modkey binds, then reuse this for
-- global keys with modkey, and for a Awesome Chord binding triggered.
-- { {mods}, key, … }
local binds = {
    -- Group: Awesome
    {{"Shift"}, "/", hotkeys_popup.show_help, {description="Show keybinds", group="Awesome"}},
    {{}, "z", actions.spawn({"wmquit"}), {description = "Quit", group = "Awesome"}},
    {{"Control"}, "z", awesome.restart, {description = "Restart Awesome", group = "Awesome"}},
    {{"Shift"}, "Escape", actions.spawn("lock-screen"), {description = "Lock screen", group = "Awesome"}},
    {
      {}, "x",
      actions.spawn({"autorandr", "--change", "--default", "horizontal"}),
      {description = "Reflow screens", group = "Awesome"}
    },

    -- Group: Client
    -- {{}, "h", focus("left"), {description = "Focus ←", group = "Client"}},
    -- {{}, "j", focus("down"), {description = "Focus ↓", group = "Client"}},
    -- {{}, "k", focus("up"), {description = "Focus ↑", group = "Client"}},
    -- {{}, "l", focus("right"), {description = "Focus →", group = "Client"}},
    {{}, "j", actions.focus_by_index(1), {description = "Focus next", group = "Client"}},
    {{}, "k", actions.focus_by_index(-1), {description = "Focus previous", group = "Client"}},
    {{"Shift"}, "j", actions.move_focused_client(1), {description = "Move next", group = "Client"}},
    {{"Shift"}, "k", actions.move_focused_client(-1), {description = "Move previous", group = "Client"}},
    {{}, "u", awful.client.urgent.jumpto, {description = "Jump to urgent", group = "Client"}},

    -- Group: Screen
    {{}, "Escape", actions.focus_screen(1), {description = "Next screen", group = "Screen"}},
    {{"Control"}, "l", actions.focus_screen(1), {description = "Next screen", group = "Screen"}},
    {{"Control"}, "h", actions.focus_screen(-1), {description = "Previous screen", group = "Screen"}},

    -- Group: Layout
    {{}, "q", actions.next_layout(), {description = "Next layout", group = "Layout"}},

    -- Group: Apps
    {{}, "Return", actions.spawn({"samedir", terminal}), {description = "Terminal in same dir", group = "Apps"}},
    {{"Shift"}, "Return", actions.spawn(terminal), {description = "Terminal", group = "Apps"}},
    {{}, "-", actions.spawn({"screenshot", "full"}), {description = "Screenshot (fullscreen)", group = "Apps"}},
    {{"Shift"}, "-", actions.spawn({"screenshot", "area"}), {description = "Screenshot (area)", group = "Apps"}},
    {{}, "p", actions.spawn({"bwmenu", "--clear", "20"}), {description = "Passwords", group = "Apps"}},

    {{},
      "w",
      actions.run_or_raise(
        {"firefox-developer-edition"},
        {class = "firefoxdeveloperedition"}
        ),
      {description = "Focus browser", group = "Apps"}
    },

    {{"Shift"},
      "w",
      actions.focus_tag_client(
        {class = "firefoxdeveloperedition"}
        ),
      {description = "Focus-tag browser", group = "Apps"}
    },

    {{},
      "e",
      actions.run_or_raise(
        {"samedir", "kitty", "nvim"},
        {class = "kitty", name = "NVIM$"}
        ),
      {description = "Focus editor", group = "Apps"}
    },

    {{"Shift"},
      "e",
      actions.focus_tag_client(
        {class = "kitty", name = "NVIM$"}
        ),
      {description = "Focus-tag editor", group = "Apps"}
    },

    {{},
      "g",
      actions.dropdown_toggle(
        {"kitty", "--class", "dropdown_kitty"},
        {class = "dropdown_kitty"}
        ),
      {description = "Terminal dropdown", group = "Apps"}
    },

    {{"Shift"},
      "g",
      actions.dropdown_toggle(
        {"kitty", "--class", "dropdown_calc", "qalc"},
        {class = "dropdown_calc"}
        ),
      {description = "Calculator dropdown", group = "Apps"}
    },

    {{},
      "t",
      actions.dropdown_toggle(
        {"kitty", "--class", "dropdown_vit", "vit"},
        {class = "dropdown_vit"}
        ),
      {description = "Tasks dropdown", group = "Apps"}
    },

    -- Group: Tag
    {{"Shift"}, "o", actions.tag_move_other_screen(), {description = "Move tag to other screen", group = "Tag"}},

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
        {{}, tostring(key_num), actions.goto_tag(i), {description = "Go to tag "..i, group = "Tag"}},

        -- Toggle tag display.
        {{"Control"}, tostring(key_num), actions.toggle_tag(i), {description = "Toggle tag "..i, group = "Tag"}},

        -- Move client to tag.
        {{"Shift"}, tostring(key_num), actions.move_to_tag(i), {description = "Move client to tag "..i, group = "Tag"}},

        -- Toggle tag on focused client.
        {{"Control", "Shift"}, tostring(key_num), actions.toggle_client_tag(i), {description = "Toggle client tag "..i, group = "Tag"}}
    })
end

local client_binds = {
    -- Basics
    {{"Shift"}, "q", actions.client_close, {description = "Kill client", group = "Client"}},

    -- Toggles
    {{}, "f", actions.client_toggle_fullscreen, {description = "Fullscreen toggle", group = "Client"}},
    {{"Shift"}, "f", actions.client_toggle_floating, {description = "Floating toggle", group = "Client"}},
    {{"Shift"}, "s", actions.client_toggle_sticky, {description = "Sticky toggle", group = "Client"}},

    -- Screen
    {{}, "o", actions.client_move_other_screen, {description = "Move client to other screen", group = "Client"}},

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
          actions.spawn({
              "rofi",
              "-show", "combi",
              "-modi", "combi,run,window,emoji",
              "-combi-modi", "drun,window,emoji"
            }),
          {description = "Rofi", group = "Apps"}
        },
        {{"Shift"},
          " ",
          actions.spawn({
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
      actions.spawn({
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
