local awful = require "awful"
local top_panel = require "layout.top-panel"
local control_center = require "layout.control-center"

screen.connect_signal("request::desktop_decoration", function(s)
  s.top_panel = top_panel(s)
  s.control_center = control_center(s)
end)

--
-- Hide top panel when apps go fullscreen
--
local function update_panel_visibility()
  for s in screen do
    if s.selected_tag then
      local is_fullscreen = (
        s.selected_tag.fullscreen_mode
        or s.selected_tag.layout == awful.layout.suit.max.fullscreen
      )

      s.top_panel.visible = not is_fullscreen
    end
  end
end

tag.connect_signal("property::selected", function(_)
  update_panel_visibility()
end)
tag.connect_signal("property::layout", function(_)
  update_panel_visibility()
end)
client.connect_signal("property::fullscreen", function(c)
  if c.first_tag then
    c.first_tag.fullscreen_mode = c.fullscreen
  end
  update_panel_visibility()
end)
client.connect_signal("unmanage", function(c)
  if c.fullscreen then
    c.screen.selected_tag.fullscreen_mode = false
    update_panel_visibility()
  end
end)
