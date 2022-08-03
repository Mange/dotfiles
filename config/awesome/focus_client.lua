local awful = require "awful"

local sharedtags = require "sharedtags"
local utils = require "utils"

local focus_client = {
  tag_name = "focused",
  previous_tags = nil,
  client = nil,
  tag = nil,
}

local function setup(c)
  focus_client.client = c
  focus_client.previous_tags = awful.screen.focused().selected_tags

  focus_client.tag = sharedtags.add(
    99, -- Should be placing this tag list in all lists
    {
      name = focus_client.tag_name,
      layout = awful.layout.suit.max,
      gap = utils.dpi(30),
      gap_single_client = true,
      volatile = true,
      clients = { c },
    }
  )

  sharedtags.viewonly(focus_client.tag)
end

local function teardown()
  awful.tag.viewmore(focus_client.previous_tags)

  if focus_client.client then
    focus_client.client:toggle_tag(focus_client.tag)
  end

  focus_client.client = nil
  focus_client.previous_tags = nil
  focus_client.tag = nil
end

function focus_client.toggle(c)
  -- Already have a client focused
  if focus_client.client and focus_client.tag then
    if focus_client.client == c then
      teardown()
    else
      sharedtags.viewonly(focus_client.tag)
    end
  else
    setup(c)
  end
end

return focus_client
