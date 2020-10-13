local spawn = require("awful.spawn")
local json = require("vendor.json")

local cmd = {"workrave-watch"}

return spawn.with_line_callback(cmd, {
    stdout = function(line)
      local status, data = pcall(json.decode, line)
      if status then
        awesome.emit_signal("mange:workrave:update", data)
      end
    end,
  })
