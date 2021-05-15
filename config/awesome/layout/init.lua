local top_panel = require("layout.top-panel")

screen.connect_signal(
  "request::desktop_decoration",
  function(s)
    s.top_panel = top_panel(s)
  end
)
