---@diagnostic disable: undefined-global

local frozen_string_literal = t { "# frozen_string_literal: true", "", "" }
local require_rails_helper = t { 'require "rails_helper"', "", "" }
local require_spec_helper = t { 'require "spec_helper"', "", "" }

return {
  s({
    trig = "#fro",
    name = "Frozen String Literal",
    snippetType = "autosnippet",
  }, frozen_string_literal),
  s({
    trig = "rdesc",
    name = "RSpec file",
  }, {
    frozen_string_literal,
    c(1, { require_rails_helper, require_spec_helper }),
  }),
}
