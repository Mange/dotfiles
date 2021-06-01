local spawn = require("awful.spawn")
local fs = require("gears.filesystem")

local icons = require("theme.icons")
local utils = require("utils")

local username = os.getenv("USER")
local expected_profile_image = "/var/lib/AccountsService/icons/" .. username

local profile = {
  username = username,
  full_name = username,
  profile_image = icons.default_profile_image,
}

function profile:refresh()
  -- Load full name
  spawn.easy_async(
    {"whoamireally"},
    ---@diagnostic disable-next-line: unused-local
    function(stdout, _stderr, _exitreason, exitcode)
      if exitcode == 0 then
        profile.full_name = utils.strip(stdout)
        awesome.emit_signal("mange:profile:update", profile)
      end
    end
  )

  -- Load profile image
  if fs.file_readable(expected_profile_image) then
    profile.profile_image = expected_profile_image
  else
    profile.profile_image = icons.default_profile_image
  end
  awesome.emit_signal("mange:profile:update", profile)
end

function profile:on_update(func)
  awesome.connect_signal("mange:profile:update", func)
end

profile:refresh()

return profile
