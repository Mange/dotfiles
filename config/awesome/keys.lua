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

keys.awesome_chord = which_keys.new_chord(
  "Awesome",
  {
    keybindings = {
      which_keys.key("space", "rofi", actions.rofi()),
      which_keys.key("Shift+space", "tydra", actions.tydra()),
      which_keys.key("e", "emoji-selector", actions.emoji_selector()),
      which_keys.key("P", "passwords", actions.passwords_menu()),

      which_keys.key_nested("a", "awesome", {
          which_keys.key("r", "restart", awesome.restart),
          which_keys.key("q", "quit/logout", actions.log_out()),
          which_keys.key("e", "edit-config", actions.edit_file(gears.filesystem.get_configuration_dir() .. "rc.lua")),
          which_keys.key("k", "edit-keys", actions.edit_file(gears.filesystem.get_configuration_dir() .. "keys.lua")),
          -- TODO -- which_keys.key("a", "toggle-aesthetics-mode", function() end),
      }),

      which_keys.key_nested("p", "power", {
          which_keys.key("s", "suspend", actions.spawn({"sh", "-c", "udiskie-umount --all && systemctl suspend"})),
          which_keys.key("h", "hibernate", actions.spawn({"sh", "-c", "udiskie-umount --all && systemctl hibernate"})),
          which_keys.key("R", "reboot", actions.log_out("reboot", "--force")),
          which_keys.key("Q", "power-off", actions.log_out("poweroff", "--force")),
          which_keys.key("l", "log-out", actions.log_out("logout", "--force")),
      }),

      which_keys.key_nested("o", "open", {
          which_keys.key("w", "wiki", actions.spawn("open-wiki")),
          which_keys.key("p", "project", actions.spawn("open-project")),
      }),

      which_keys.key_nested("s", "screenshot", {
          which_keys.key("s", "specific-area", actions.screenshot("area")),
          which_keys.key("a", "all-screen", actions.screenshot("full")),
          which_keys.key("w", "window", actions.screenshot("current-window")),
      })
    },
    timeout = 5
  }
)

keys.global = gears.table.join(
    -- Group: Awesome
    awful.key({modkey, "Shift"}, "/", hotkeys_popup.show_help, {description="Show keybinds", group="Awesome"}),
    awful.key({modkey}, "z", actions.log_out(), {description = "Quit", group = "Awesome"}),
    awful.key({modkey, "Control"}, "z", awesome.restart, {description = "Restart Awesome", group = "Awesome"}),
    awful.key({modkey, "Shift"}, "Escape", actions.spawn("lock-screen"), {description = "Lock screen", group = "Awesome"}),
    awful.key(
      {modkey}, "x",
      actions.spawn({"autorandr", "--change", "--default", "horizontal"}),
      {description = "Reflow screens", group = "Awesome"}
    ),
    awful.key({modkey},
      "space",
      keys.awesome_chord.enter,
      {description = "Chord", group = "Awesome"}
    ),

    awful.key({modkey}, "i", actions.dismiss_notification(), {description = "Dismiss notification", group = "Awesome"}),


    awful.key({modkey, "Shift"}, "i", actions.dismiss_all_notifications(), {description = "Dismiss all notifications", group = "Awesome"}),

    -- Group: Client
    -- awful.key({modkey}, "h", focus("left"), {description = "Focus ←", group = "Client"}),
    -- awful.key({modkey}, "j", focus("down"), {description = "Focus ↓", group = "Client"}),
    -- awful.key({modkey}, "k", focus("up"), {description = "Focus ↑", group = "Client"}),
    -- awful.key({modkey}, "l", focus("right"), {description = "Focus →", group = "Client"}),
    awful.key({modkey}, "j", actions.focus_by_index(1), {description = "Focus next", group = "Client"}),
    awful.key({modkey}, "k", actions.focus_by_index(-1), {description = "Focus previous", group = "Client"}),
    awful.key({modkey, "Shift"}, "j", actions.move_focused_client(1), {description = "Move next", group = "Client"}),
    awful.key({modkey, "Shift"}, "k", actions.move_focused_client(-1), {description = "Move previous", group = "Client"}),
    awful.key({modkey}, "u", awful.client.urgent.jumpto, {description = "Jump to urgent", group = "Client"}),

    -- Group: Screen
    awful.key({modkey}, "Escape", actions.focus_screen(1), {description = "Next screen", group = "Screen"}),
    awful.key({modkey, "Control"}, "l", actions.focus_screen(1), {description = "Next screen", group = "Screen"}),
    awful.key({modkey, "Control"}, "h", actions.focus_screen(-1), {description = "Previous screen", group = "Screen"}),

    -- Group: Layout
    awful.key({modkey}, "q", actions.next_layout(), {description = "Next layout", group = "Layout"}),

    -- Group: Apps
    awful.key({modkey, "Shift"}, "space", actions.rofi(), {description = "Rofi", group = "Apps"}),

    awful.key({modkey}, "Return", actions.spawn({"samedir", terminal}), {description = "Terminal in same dir", group = "Apps"}),
    awful.key({modkey, "Shift"}, "Return", actions.spawn(terminal), {description = "Terminal", group = "Apps"}),
    awful.key({modkey}, "-", actions.screenshot("full"), {description = "Screenshot (fullscreen)", group = "Apps"}),
    awful.key({modkey, "Shift"}, "-", actions.screenshot("area"), {description = "Screenshot (area)", group = "Apps"}),
    awful.key({modkey}, "p", actions.passwords_menu(), {description = "Passwords", group = "Apps"}),

    awful.key(
      {modkey}, "w",
      actions.run_or_raise(
        {"firefox-developer-edition"},
        {class = "firefoxdeveloperedition"}
        ),
      {description = "Focus browser", group = "Apps"}
    ),

    awful.key(
      {modkey, "Shift"}, "w",
      actions.focus_tag_client(
        {class = "firefoxdeveloperedition"}
        ),
      {description = "Focus-tag browser", group = "Apps"}
    ),

    awful.key(
      {modkey}, "e",
      actions.run_or_raise(
        {"samedir", "kitty", "nvim"},
        {class = "kitty", name = "NVIM$"}
        ),
      {description = "Focus editor", group = "Apps"}
    ),

    awful.key(
      {modkey, "Shift"}, "e",
      actions.focus_tag_client(
        {class = "kitty", name = "NVIM$"}
        ),
      {description = "Focus-tag editor", group = "Apps"}
    ),

    awful.key(
      {modkey}, "g",
      actions.dropdown_toggle(
        {"kitty", "--class", "dropdown_kitty"},
        {class = "dropdown_kitty"}
        ),
      {description = "Terminal dropdown", group = "Apps"}
    ),

    awful.key(
      {modkey, "Shift"}, "g",
      actions.dropdown_toggle(
        {"kitty", "--class", "dropdown_calc", "qalc"},
        {class = "dropdown_calc"}
      ),
      {description = "Calculator dropdown", group = "Apps"}
    ),

    awful.key(
      {modkey}, "t",
      actions.dropdown_toggle(
        {"kitty", "--class", "dropdown_vit", "vit"},
        {class = "dropdown_vit"}
        ),
      {description = "Tasks dropdown", group = "Apps"}
    ),

    -- Group: Tag
    awful.key({modkey, "Shift"}, "o", actions.tag_move_other_screen(), {description = "Move tag to other screen", group = "Tag"}),

    -- Group: Modes
    awful.key({modkey, }, "m", media_mode.enter, {description = "Enter media mode", group = "Modes"}),

    --
    -- Vanilla; to be moved and sorted
    --


    -- Layout manipulation
    awful.key(
      {modkey, }, "Tab",
      function ()
        awful.client.focus.history.previous()
        if client.focus then
          client.focus:raise()
        end
      end,
      {description = "go back", group = "client"}
    ),

    -- Standard program

    -- {{}, "l",     function () awful.tag.incmwfact( 0.05)          end,
    -- {description = "increase master width factor", group = "layout"}},
    -- {{}, "h",     function () awful.tag.incmwfact(-0.05)          end,
    -- {description = "decrease master width factor", group = "layout"}},
    awful.key({modkey, "Shift"}, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
      {description = "increase the number of master clients", group = "layout"}),
    awful.key({modkey, "Shift"}, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
      {description = "decrease the number of master clients", group = "layout"}),
    awful.key({modkey, "Control"}, "h",     function () awful.tag.incncol( 1, nil, true)    end,
      {description = "increase the number of columns", group = "layout"}),
    awful.key({modkey, "Control"}, "l",     function () awful.tag.incncol(-1, nil, true)    end,
      {description = "decrease the number of columns", group = "layout"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 10 do
    local key_num = i % 10 -- Turn 10 into 0

    keys.global = gears.table.join(
        keys.global,

        -- View tag only.
        awful.key({modkey}, tostring(key_num), actions.goto_tag(i), {description = "Go to tag "..i, group = "Tag"}),

        -- Toggle tag display.
        awful.key({modkey, "Control"}, tostring(key_num), actions.toggle_tag(i), {description = "Toggle tag "..i, group = "Tag"}),

        -- Move client to tag.
        awful.key({modkey, "Shift"}, tostring(key_num), actions.move_to_tag(i), {description = "Move client to tag "..i, group = "Tag"}),

        -- Toggle tag on focused client.
        awful.key({modkey, "Control", "Shift"}, tostring(key_num), actions.toggle_client_tag(i), {description = "Toggle client tag "..i, group = "Tag"})
    )
end

keys.clientkeys = gears.table.join(
    -- Basics
    awful.key({modkey, "Shift"}, "q", actions.client_close, {description = "Kill client", group = "Client"}),

    -- Toggles
    awful.key({modkey}, "f", actions.client_toggle_fullscreen, {description = "Fullscreen toggle", group = "Client"}),
    awful.key({modkey, "Shift"}, "f", actions.client_toggle_floating, {description = "Floating toggle", group = "Client"}),
    awful.key({modkey, "Shift"}, "s", actions.client_toggle_sticky, {description = "Sticky toggle", group = "Client"}),

    -- Screen
    awful.key({modkey}, "o", actions.client_move_other_screen, {description = "Move client to other screen", group = "Client"}),

    --
    -- Vanilla; to be moved and sorted
    --
    awful.key({modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end, {description = "move to master", group = "client"})
)

return keys
