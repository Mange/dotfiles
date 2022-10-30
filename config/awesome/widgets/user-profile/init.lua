local awful = require "awful"
local wibox = require "wibox"
local gears = require "gears"
local beautiful = require "beautiful"

local dpi = require("utils").dpi
local keys = require "keys"
local profile = require "module.daemons.profile"

local create_profile = function()
  local profile_imagebox = wibox.widget {
    {
      widget = wibox.widget.imagebox,
      id = "icon",
      image = profile.profile_image,
      resize = true,
      forced_height = dpi(28),
      clip_shape = beautiful.groups.shape,
    },
    layout = wibox.layout.align.horizontal,
  }

  local profile_name = wibox.widget {
    widget = wibox.widget.textbox,
    markup = profile.full_name,
    font = beautiful.font_size(10),
    align = "left",
    valign = "center",
  }

  local user_profile = wibox.widget {
    layout = wibox.layout.fixed.horizontal,
    spacing = dpi(5),
    {
      layout = wibox.layout.align.vertical,
      expand = "none",
      nil,
      profile_imagebox,
      nil,
    },
    profile_name,
  }

  local refresh = function(update)
    profile_imagebox.icon:set_image(update.profile_image)
    profile_name:set_markup(update.full_name)
  end
  profile:on_update(refresh)

  profile_imagebox:buttons(
    gears.table.join(
      awful.button({}, keys.left_click, nil, function()
        awful.spawn.single_instance "mugshot"
      end),
      awful.button({}, keys.right_click, nil, function()
        profile:refresh()
      end)
    )
  )

  return user_profile
end

return create_profile
