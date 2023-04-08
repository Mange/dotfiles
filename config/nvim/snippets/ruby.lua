---@diagnostic disable: undefined-global
local unpack = unpack or table.unpack

local filename = function()
  return f(function(_args, snip)
    return snip.snippet.env.TM_FILENAME
  end)
end

local nl = function(num)
  local n = num or 1
  local lines = {}
  for _ = 1, n do
    table.insert(lines, "")
  end

  return t(lines)
end

local frozen_string_literal = function()
  return t { "# frozen_string_literal: true", "", "" }
end

local require_custom = function(suggestion)
  return fmt(
    'require "{file}"\n{cursor}',
    { file = i(1, suggestion or "some_file"), cursor = i(0) }
  )
end

local require_rails_helper = function()
  return t { 'require "rails_helper"', "", "" }
end

return {
  --- Plain Ruby snippets

  s({
    trig = "#fro",
    name = "Frozen string literal",
    snippetType = "autosnippet",
  }, { frozen_string_literal(), nl(1), i(0) }),

  s("req", require_custom "some_file"),

  --- RSpec snippets

  s({
    trig = "rdesc",
    name = "RSpec file",
    -- snippetType = "autosnippet",
  }, {
    frozen_string_literal(),
    nl(),
    c(1, {
      require_rails_helper(),
      require_custom "spec_helper",
    }),
    nl(),
    unpack(fmt(
      [[
        RSpec.describe {name} do
          {cursor}
        end
      ]],
      {
        name = i(2, "SomeClass"),
        cursor = i(0),
      }
    )),
  }),

  s(
    "let",
    fmt("let(:{name}) {{ {value} }}\n{cursor}", {
      name = i(1, "name"),
      value = i(2, "value"),
      cursor = i(0),
    })
  ),
}
