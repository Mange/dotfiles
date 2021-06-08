local wibox = require("wibox")
local beautiful = require("beautiful")

local song_info = {}

song_info.music_title = wibox.widget {
  layout = wibox.layout.fixed.horizontal,
  expand = "none",
  {
    id = "title_scroll",
    max_size = 150,
    speed = 75,
    expand = true,
    direction = "h",
    step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
    fps = 30,
    layout = wibox.container.scroll.horizontal,
    {
      id = "title",
      text = "title",
      font = beautiful.font_bold_size(10),
      align  = "left",
      valign = "center",
      ellipsize = "end",
      widget = wibox.widget.textbox
    },
  }
}

song_info.music_artist = wibox.widget {
  layout = wibox.layout.fixed.horizontal,
  expand = "none",
  {
    id = "artist_scroll",
    max_size = 150,
    speed = 75,
    expand = true,
    direction = "h",
    step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
    fps = 30,
    layout = wibox.container.scroll.horizontal,
    {
      id = "artist",
      text = "artist",
      font = beautiful.font_size(10),
      align  = "left",
      valign = "center",
      widget = wibox.widget.textbox
    },
  }
}

song_info.music_info = wibox.widget {
  layout = wibox.layout.align.vertical,
  expand = "none",
  nil,
  {
    layout = wibox.layout.fixed.vertical,
    song_info.music_title,
    song_info.music_artist
  },
  nil
}

return song_info
