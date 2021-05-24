local top_panel = require("layout.top-panel")

screen.connect_signal(
  "request::desktop_decoration",
  function(s)
    s.top_panel = top_panel(s)
  end
)

--
-- Hide top panel when apps go fullscreen
--
function update_panel_visibility()
  for s in screen do
    if s.selected_tag then
      local is_fullscreen = s.selected_tag.fullscreen_mode

      s.top_panel.visible = not is_fullscreen
    end
  end
end

tag.connect_signal("property::selected", function(_) update_panel_visibility() end)
client.connect_signal(
  "property::fullscreen",
  function(c)
    if c.first_tag then
      c.first_tag.fullscreen_mode = c.fullscreen
    end
    update_panel_visibility()
  end
)
client.connect_signal(
  "unmanage",
  function(c)
    if c.fullscreen then
      c.screen.selected_tag.fullscreen_mode = false
      update_panel_visibility()
    end
  end
)