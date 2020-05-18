local gears = require("gears")
local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

local utils = require("utils")

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

local function run_or_raise(cmd, matcher)
  return function()
    utils.run_or_raise(cmd, matcher)
  end
end

local function dropdown_toggle(cmd, rule)
  return function()
    dropdown.toggle(cmd, rule)
  end
end

keys.global = gears.table.join(
    -- Group: Awesome
    awful.key({modkey, "Shift"}, "/", hotkeys_popup.show_help, {description="Show keybinds", group="Awesome"}),
    awful.key({modkey}, "z", quit_menu, {description = "Quit", group = "Awesome"}),
    awful.key({modkey, "Control"}, "z", awesome.restart, {description = "Restart Awesome", group = "Awesome"}),

    -- Group: Client
    -- awful.key({modkey}, "h", focus("left"), {description = "Focus ←", group = "Client"}),
    -- awful.key({modkey}, "j", focus("down"), {description = "Focus ↓", group = "Client"}),
    -- awful.key({modkey}, "k", focus("up"), {description = "Focus ↑", group = "Client"}),
    -- awful.key({modkey}, "l", focus("right"), {description = "Focus →", group = "Client"}),
    awful.key({modkey}, "j", focus_idx(1), {description = "Focus next", group = "Client"}),
    awful.key({modkey}, "k", focus_idx(-1), {description = "Focus previous", group = "Client"}),
    awful.key({modkey, "Shift"}, "j", move_focused_idx(1), {description = "Move next", group = "Client"}),
    awful.key({modkey, "Shift"}, "k", move_focused_idx(-1), {description = "Move previous", group = "Client"}),
    awful.key({modkey}, "u", awful.client.urgent.jumpto, {description = "Jump to urgent", group = "Client"}),

    -- Group: Screen
    awful.key({modkey}, "Escape", focus_screen(1), {description = "Next screen", group = "Screen"}),
    awful.key({modkey, "Control"}, "l", focus_screen(1), {description = "Next screen", group = "Screen"}),
    awful.key({modkey, "Control"}, "h", focus_screen(-1), {description = "Previous screen", group = "Screen"}),

    -- Group: Layout
    awful.key({modkey}, "q", next_layout, {description = "Next layout", group = "Layout"}),

    -- Group: Apps
    awful.key({modkey}, "Return", spawn({"samedir", terminal}), {description = "Terminal in same dir", group = "Apps"}),
    awful.key({modkey, "Shift"}, "Return", spawn(terminal), {description = "Terminal", group = "Apps"}),
    awful.key(
      {modkey},
      "space",
      spawn({
          "rofi",
          "-show", "combi",
          "-modi", "combi,run,window,emoji",
          "-combi-modi", "drun,window,emoji"
      }),
      {description = "Rofi", group = "Apps"}
    ),
    awful.key(
      {modkey, "Shift"},
      "space",
      spawn({
          "kitty",
          "--class", "dropdown_tydra",
          "zsh", "-ic", "tydra ~/.config/tydra/main.yml"
      }),
      {description = "Tydra", group = "Apps"}
    ),

    awful.key(
      {modkey},
      "w",
      run_or_raise(
        {"firefox-developer-edition"},
        {class = "firefoxdeveloperedition"}
      ),
      {description = "Focus browser", group = "Apps"}
    ),

    awful.key(
      {modkey},
      "e",
      run_or_raise(
        {"samedir", "kitty", "nvim"},
        {class = "kitty", name = "NVIM$"}
      ),
      {description = "Focus editor", group = "Apps"}
    ),

    awful.key(
      {modkey},
      "g",
      dropdown_toggle(
        {"kitty", "--class", "dropdown_kitty"},
        {class = "dropdown_kitty"}
      ),
      {description = "Terminal dropdown", group = "Apps"}
    ),

    --
    -- Vanilla; to be moved and sorted
    --


    -- Layout manipulation
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program

    -- awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              -- {description = "increase master width factor", group = "layout"}),
    -- awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              -- {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    keys.global = gears.table.join(keys.global,
        -- View tag only.
        awful.key({ keys.modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ keys.modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ keys.modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ keys.modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

keys.clientkeys = gears.table.join(
    -- Basics
    awful.key({modkey, "Shift"}, "q", client_close, {description = "Kill client", group = "Client"}),
    awful.key({modkey}, "f", client_toggle_fullscreen, {description = "Fullscreen toggle", group = "Client"}),
    awful.key({modkey, "Shift"}, "f", client_toggle_floating, {description = "Floating toggle", group = "Client"}),
    awful.key({modkey, "Shift"}, "s", client_toggle_sticky, {description = "Sticky toggle", group = "Client"}),

    --
    -- Vanilla; to be moved and sorted
    --
    awful.key({ keys.modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ keys.modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"})
)

return keys
