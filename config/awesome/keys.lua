local gears = require("gears")
local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")

-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- Settings
local modkey = "Mod4" -- Super
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

local function client_close(c)
  c:kill()
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

    -- Group: Screen
    awful.key({modkey}, "Escape", focus_screen(1), {description = "Next screen", group = "Screen"}),
    awful.key({modkey, "Control"}, "l", focus_screen(1), {description = "Next screen", group = "Screen"}),
    awful.key({modkey, "Control"}, "h", focus_screen(-1), {description = "Previous screen", group = "Screen"}),

    -- Group: Tag

    -- Group: Apps
    awful.key({modkey}, "Return", spawn({"samedir", terminal}), {description = "Terminal in same dir", group = "Apps"}),
    awful.key({modkey, "Shift"}, "Return", spawn(terminal), {description = "Terminal", group = "Apps"}),

    --
    -- Vanilla; to be moved and sorted
    --


    -- Layout manipulation
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
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
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

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
    awful.key({keys.modkey, "Shift"}, "q", client_close, {description = "Kill client", group = "Client"}),

    --
    -- Vanilla; to be moved and sorted
    --
    awful.key({ keys.modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ keys.modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ keys.modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ keys.modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ keys.modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ keys.modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ keys.modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ keys.modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ keys.modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

return keys
