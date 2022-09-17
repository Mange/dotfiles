local gears = require "gears"
local awful = require "awful"
local beautiful = require "beautiful"
local hotkeys_popup = require "awful.hotkeys_popup"
local bling = require "vendor.bling"

local constants = require "module.constants"
local actions = require "actions"
local which_keys = require "module.which_keys" --[[@as WhichKeys]]
local wk = which_keys.key
local media_mode = require "media_mode"

-- Settings
local modkey = constants.keys.modkey
-- Terminal cmdline; note that this is repeated in this file some times because
-- of non-standard CLI arguments, etc.
local terminal = "wezterm"

local keys = {}

-- DEPRECATED
keys.left_click = 1
keys.middle_click = 2
keys.right_click = 3
keys.scroll_up = 4
keys.scroll_down = 5

-- Export some variables
-- DEPRECATED
keys.modkey = modkey

keys.awesome_chord = which_keys.new_chord("Awesome", {
  keybindings = {
    wk("w", "window-select", actions.select_window()),
    wk("e", "emoji-selector", actions.emoji_selector()),
    wk("P", "passwords", actions.passwords_menu()),
    wk(
      "m",
      "+media",
      media_mode.enter,
      { which_key_colors = beautiful.which_key.nested }
    ),

    wk("n", "minimize", actions.on_focused_client(actions.client_minimize)),
    wk("N", "unminimize-random", actions.unminimize_random()),

    which_keys.key_nested("a", "awesome", {
      wk("r", "restart", awesome.restart),
      wk("q", "quit/logout", actions.log_out()),
      wk(
        "e",
        "edit-config",
        actions.edit_file(gears.filesystem.get_configuration_dir() .. "rc.lua")
      ),
      wk(
        "k",
        "edit-keys",
        actions.edit_file(
          gears.filesystem.get_configuration_dir() .. "keys.lua"
        )
      ),
      -- TODO -- wk("a", "toggle-aesthetics-mode", function() end),
    }),

    which_keys.key_nested("t", "toggle", {
      wk("d", "calendar-popup", actions.toggle_calendar_popup()),
      wk("c", "control-center", actions.toggle_control_center()),
      wk("s", "systray", actions.toggle_systray()),
      wk("f", "toggle-focus-mode", actions.toggle_focus_tag()),
    }),

    which_keys.key_nested("p", "power", {
      wk(
        "s",
        "suspend",
        actions.spawn {
          "sh",
          "-c",
          "udiskie-umount --all && systemctl suspend-then-hibernate",
        }
      ),
      wk(
        "h",
        "hibernate",
        actions.spawn {
          "sh",
          "-c",
          "udiskie-umount --all && systemctl hibernate",
        }
      ),
      wk("R", "reboot", actions.log_out("reboot", "--force")),
      wk("Q", "power-off", actions.log_out("poweroff", "--force")),
      wk("l", "log-out", actions.log_out("logout", "--force")),
    }),

    which_keys.key_nested("o", "open", {
      wk("w", "wiki", actions.spawn "open-wiki"),
      wk("p", "project", actions.spawn "open-project"),
      wk("d", "dotfile", actions.spawn { "dotfiles", "edit" }),
    }),

    which_keys.key_nested("c", "client", {
      wk("r", "restore", actions.on_focused_client(actions.client_restore)),
      wk("m", "minimize", actions.on_focused_client(actions.client_minimize)),
      wk("n", "next", actions.focus_by_index(1), { which_key_sticky = true }),
      wk(
        "p",
        "previous",
        actions.focus_by_index(-1),
        { which_key_sticky = true }
      ),
      wk(
        "s",
        "sticky-toggle",
        actions.on_focused_client(actions.client_toggle_sticky)
      ),
      wk(
        "t",
        "ontop-toggle",
        actions.on_focused_client(actions.client_toggle_ontop)
      ),
      wk(
        "q",
        "titlebar-toggle",
        actions.on_focused_client(actions.client_toggle_titlebar)
      ),
      wk(
        "f",
        "fullscreen-toggle",
        actions.on_focused_client(actions.client_toggle_fullscreen)
      ),
      wk("q", "close", actions.on_focused_client(actions.client_close)),
      wk(
        "o",
        "move-other-screen",
        actions.on_focused_client(actions.client_move_other_screen)
      ),

      -- TODO: Keys to move to tags 1-9
    }),

    which_keys.key_nested("l", "layout", {
      wk(
        "[",
        "previous",
        actions.previous_layout(),
        { which_key_sticky = true }
      ),
      wk("]", "next", actions.next_layout(), { which_key_sticky = true }),

      wk("f", "floating", actions.set_layout(awful.layout.suit.floating)),
      wk("c", "centered", actions.set_layout(bling.layout.centered)),
      wk("d", "deck", actions.set_layout(bling.layout.deck)),
      wk("t", "tabbed", actions.set_layout(bling.layout.mstab)),
      wk("l", "master-right", actions.set_layout(awful.layout.suit.tile.left)),
      wk("h", "master-left", actions.set_layout(awful.layout.suit.tile)),
      wk("j", "master-up", actions.set_layout(awful.layout.suit.tile.bottom)),
      wk("k", "master-down", actions.set_layout(awful.layout.suit.tile.top)),
      wk("=", "equal-area", actions.set_layout(bling.layout.equalarea)),
      wk("n", "fair", actions.set_layout(awful.layout.suit.fair)),
      wk(
        "m",
        "fair-horiz",
        actions.set_layout(awful.layout.suit.fair.horizontal)
      ),
      wk("u", "spiral", actions.set_layout(awful.layout.suit.spiral)),
      wk("b", "bsp", actions.set_layout(awful.layout.suit.spiral.dwindle)),
      wk("i", "max", actions.set_layout(awful.layout.suit.max)),
      wk(
        "I",
        "max-fullscreen",
        actions.set_layout(awful.layout.suit.max.fullscreen)
      ),
      wk("o", "magnifier", actions.set_layout(awful.layout.suit.magnifier)),
      wk("w", "corner-nw", actions.set_layout(awful.layout.suit.corner.nw)),
      wk("W", "corner-sw", actions.set_layout(awful.layout.suit.corner.sw)),
      wk("e", "corner-ne", actions.set_layout(awful.layout.suit.corner.ne)),
      wk("E", "corner-se", actions.set_layout(awful.layout.suit.corner.se)),
    }),

    which_keys.key_nested("s", "screenshot", {
      wk("s", "specific-area", actions.flameshot "gui"),
      wk("a", "all-screen", actions.flameshot "screen"),
      wk("f", "full-screen", actions.flameshot "desktop"),

      which_keys.key_nested("d", "delayed", {
        wk("s", "specific-area", actions.flameshot("gui", "--delay", "5000")),
        wk("a", "all-screen", actions.flameshot("screen", "--delay", "5000")),
        wk("d", "all-desktop", actions.flameshot("desktop", "--delay", "5000")),
      }),
    }),
  },
})

keys.global = gears.table.join(
  -- Group: Hidden
  awful.key({}, "XF86MonBrightnessUp", actions.brightness_change "+5%"),
  awful.key({}, "XF86MonBrightnessDown", actions.brightness_change "5%-"),
  awful.key({}, "XF86AudioRaiseVolume", actions.volume_change "+5"),
  awful.key({}, "XF86AudioLowerVolume", actions.volume_change "-5"),
  awful.key({}, "XF86AudioMute", actions.volume_mute_toggle()),
  awful.key({}, "XF86AudioPlay", actions.playerctl_play_pause()),

  -- Group: Awesome
  awful.key(
    { modkey, "Shift" },
    "/",
    hotkeys_popup.show_help,
    { description = "Show keybinds", group = "Awesome" }
  ),
  awful.key(
    { modkey },
    "z",
    actions.log_out(),
    { description = "Quit", group = "Awesome" }
  ),
  awful.key(
    { modkey, "Control" },
    "z",
    awesome.restart,
    { description = "Restart Awesome", group = "Awesome" }
  ),
  awful.key(
    { modkey, "Shift" },
    "Escape",
    actions.spawn "lock-screen",
    { description = "Lock screen", group = "Awesome" }
  ),
  awful.key(
    { "Ctrl", "Shift" },
    "Escape",
    actions.spawn "fix-keyboard",
    { description = "Fix keyboard", group = "Awesome" }
  ),
  awful.key(
    { modkey },
    "x",
    actions.spawn { "autorandr", "--change", "--default", "horizontal" },
    { description = "Reflow screens", group = "Awesome" }
  ),
  awful.key(
    { modkey },
    "space",
    keys.awesome_chord.enter,
    { description = "Chord", group = "Awesome" }
  ),

  awful.key(
    { modkey },
    "i",
    actions.dismiss_notification(),
    { description = "Dismiss notification", group = "Awesome" }
  ),

  awful.key(
    { modkey, "Shift" },
    "i",
    actions.dismiss_all_notifications(),
    { description = "Dismiss all notifications", group = "Awesome" }
  ),

  -- Group: Client
  awful.key(
    { modkey },
    "h",
    actions.focus "left",
    { description = "Focus ←", group = "Client" }
  ),
  awful.key(
    { modkey },
    "j",
    actions.focus "down",
    { description = "Focus ↓", group = "Client" }
  ),
  awful.key(
    { modkey },
    "k",
    actions.focus "up",
    { description = "Focus ↑", group = "Client" }
  ),
  awful.key(
    { modkey },
    "l",
    actions.focus "right",
    { description = "Focus →", group = "Client" }
  ),
  awful.key(
    { modkey, "Shift" },
    "j",
    actions.move_focused_client(1),
    { description = "Move next", group = "Client" }
  ),
  awful.key(
    { modkey, "Shift" },
    "k",
    actions.move_focused_client(-1),
    { description = "Move previous", group = "Client" }
  ),
  awful.key(
    { modkey },
    "u",
    awful.client.urgent.jumpto,
    { description = "Jump to urgent", group = "Client" }
  ),

  -- Group: Screen
  awful.key(
    { modkey },
    "Escape",
    actions.focus_screen(1),
    { description = "Next screen", group = "Screen" }
  ),
  awful.key(
    { modkey },
    ";",
    actions.focus_screen_dir "left",
    { description = "← Screen", group = "Screen" }
  ),
  awful.key(
    { modkey },
    "'",
    actions.focus_screen_dir "right",
    { description = "Screen →", group = "Screen" }
  ),

  -- Group: Layout
  awful.key(
    { modkey },
    "q",
    actions.next_layout(),
    { description = "Next layout", group = "Layout" }
  ),

  -- Group: Apps
  awful.key(
    { modkey },
    "d",
    actions.rofi(),
    { description = "Rofi", group = "Apps" }
  ),

  awful.key(
    { modkey },
    "Return",
    actions.spawn { "samedirwezterm" },
    { description = "Terminal in same dir", group = "Apps" }
  ),
  awful.key(
    { modkey, "Shift" },
    "Return",
    actions.spawn(terminal),
    { description = "Terminal", group = "Apps" }
  ),

  awful.key(
    { modkey },
    "w",
    actions.run_or_raise({ "brave-browser-beta" }, { class = "Brave" }),
    { description = "Focus browser", group = "Apps" }
  ),

  awful.key(
    { modkey, "Shift" },
    "w",
    actions.focus_tag_client { class = "Brave" },
    { description = "Focus-tag browser", group = "Apps" }
  ),

  awful.key(
    { modkey },
    "e",
    actions.run_or_raise(
      { "samedirwezterm", "start", "--", "nvim" },
      { class = "org.wezfurlong.wezterm", name = "NVIM$" }
    ),
    { description = "Focus editor", group = "Apps" }
  ),

  awful.key(
    { modkey, "Shift" },
    "e",
    actions.focus_tag_client {
      class = "org.wezfurlong.wezterm",
      name = "NVIM$",
    },
    { description = "Focus-tag editor", group = "Apps" }
  ),

  awful.key(
    { modkey },
    "g",
    actions.dropdown_toggle(
      { "samedirwezterm", "start", "--class", "dropdown_terminal" },
      { class = "dropdown_terminal" }
    ),
    { description = "Terminal dropdown", group = "Apps" }
  ),

  awful.key(
    { modkey, "Shift" },
    "g",
    actions.dropdown_toggle(
      { "wezterm", "start", "--class", "dropdown_calc", "--", "qalc" },
      { class = "dropdown_calc" }
    ),
    { description = "Calculator dropdown", group = "Apps" }
  ),

  awful.key(
    { modkey },
    "t",
    actions.dropdown_toggle(
      { "wezterm", "start", "--class", "dropdown_vit", "--", "vit" },
      { class = "dropdown_vit" }
    ),
    { description = "Tasks dropdown", group = "Apps" }
  ),

  -- Group: Tag
  awful.key(
    { modkey, "Shift" },
    "o",
    actions.tag_move_other_screen(),
    { description = "Move tag to other screen", group = "Tag" }
  ),

  -- Group: Modes
  awful.key(
    { modkey },
    "m",
    media_mode.enter,
    { description = "Enter media mode", group = "Modes" }
  ),

  --
  -- Vanilla; to be moved and sorted
  --

  -- Layout manipulation
  awful.key({ modkey }, "Tab", function()
    awful.client.focus.history.previous()
    if client.focus then
      client.focus:raise()
    end
  end, { description = "go back", group = "client" }),

  -- Standard program

  -- {{}, "l",     function () awful.tag.incmwfact( 0.05)          end,
  -- {description = "increase master width factor", group = "layout"}},
  -- {{}, "h",     function () awful.tag.incmwfact(-0.05)          end,
  -- {description = "decrease master width factor", group = "layout"}},
  awful.key(
    { modkey, "Shift" },
    "h",
    function()
      awful.tag.incnmaster(1, nil, true)
    end,
    { description = "increase the number of master clients", group = "layout" }
  ),
  awful.key(
    { modkey, "Shift" },
    "l",
    function()
      awful.tag.incnmaster(-1, nil, true)
    end,
    { description = "decrease the number of master clients", group = "layout" }
  ),
  awful.key({ modkey, "Control" }, "h", function()
    awful.tag.incncol(1, nil, true)
  end, { description = "increase the number of columns", group = "layout" }),
  awful.key({ modkey, "Control" }, "l", function()
    awful.tag.incncol(-1, nil, true)
  end, { description = "decrease the number of columns", group = "layout" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 10 do
  local key_num = i % 10 -- Turn 10 into 0

  keys.global = gears.table.join(
    keys.global,

    -- View tag only.
    awful.key(
      { modkey },
      tostring(key_num),
      actions.goto_tag(i),
      { description = "Go to tag " .. i, group = "Tag" }
    ),

    -- Toggle tag display.
    awful.key(
      { modkey, "Control" },
      tostring(key_num),
      actions.toggle_tag(i),
      { description = "Toggle tag " .. i, group = "Tag" }
    ),

    -- Move client to tag.
    awful.key(
      { modkey, "Shift" },
      tostring(key_num),
      actions.move_to_tag(i),
      { description = "Move client to tag " .. i, group = "Tag" }
    ),

    -- Toggle tag on focused client.
    awful.key(
      { modkey, "Control", "Shift" },
      tostring(key_num),
      actions.toggle_client_tag(i),
      { description = "Toggle client tag " .. i, group = "Tag" }
    )
  )
end

keys.clientkeys = gears.table.join(
  -- Basics
  awful.key(
    { modkey, "Shift" },
    "q",
    actions.client_close,
    { description = "Kill client", group = "Client" }
  ),
  awful.key(
    { modkey },
    "n",
    actions.focus_by_index(1),
    { description = "Next client", group = "Client" }
  ),
  awful.key(
    { modkey },
    "p",
    actions.focus_by_index(-1),
    { description = "Previous client", group = "Client" }
  ),

  -- Toggles
  awful.key(
    { modkey },
    "f",
    actions.client_toggle_fullscreen,
    { description = "Fullscreen toggle", group = "Client" }
  ),
  awful.key(
    { modkey, "Shift" },
    "f",
    actions.client_toggle_floating,
    { description = "Floating toggle", group = "Client" }
  ),
  awful.key(
    { modkey, "Shift" },
    "s",
    actions.client_toggle_sticky,
    { description = "Sticky toggle", group = "Client" }
  ),

  -- Screen
  awful.key(
    { modkey },
    "o",
    actions.client_move_other_screen,
    { description = "Move client to other screen", group = "Client" }
  ),

  --
  -- Vanilla; to be moved and sorted
  --
  awful.key({ modkey, "Control" }, "Return", function(c)
    c:swap(awful.client.getmaster())
  end, { description = "move to master", group = "client" })
)

keys.mouse_click = function(modifier, button, action)
  return gears.table.join(awful.button(modifier, button, nil, action))
end

return keys
