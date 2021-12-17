local luaunit = require "luaunit"

local Bind = require "module.which_keys.bind"
local which_key_theme = require("theme").which_key

local identity = function(x)
  return x
end

local TestWhichKeysBind = {}

function TestWhichKeysBind:testInitialize()
  local bind = Bind.new({}, "a", identity, { description = "AAAA!" })

  luaunit.assertEquals(bind.modifiers, {})
  luaunit.assertEquals(bind.key, "a")
  luaunit.assertEquals(bind.action, identity)
  luaunit.assertEquals(bind.details.description, "AAAA!")
end

function TestWhichKeysBind:testDefaultFields()
  local bind = Bind.new({}, "a", identity)

  luaunit.assertEquals(bind.key_label, "a")
  luaunit.assertEquals(bind.action_label, "no-description")
  luaunit.assertEquals(bind.colors, which_key_theme.normal)
  luaunit.assertEquals(bind.is_hidden, false)
  luaunit.assertEquals(bind.is_sticky, false)
  luaunit.assertEquals(bind.sort_key, "a1")
end

function TestWhichKeysBind:testKeyLabel()
  local x = Bind.new({}, "x", identity)
  luaunit.assertEquals(x.key_label, "x")
  luaunit.assertEquals(x.sort_key, "x1")

  local shift_x = Bind.new({ "Shift" }, "x", identity)
  luaunit.assertEquals(shift_x.key_label, "X")
  luaunit.assertEquals(shift_x.sort_key, "x2")

  local ctrl_x = Bind.new({ "Control" }, "X", identity)
  luaunit.assertEquals(ctrl_x.key_label, "C-x")
  luaunit.assertEquals(ctrl_x.sort_key, "x3")

  local cs_x = Bind.new({ "Control", "Shift" }, "x", identity)
  luaunit.assertEquals(cs_x.key_label, "C-X")
  luaunit.assertEquals(cs_x.sort_key, "x3")

  local sc_x = Bind.new({ "Shift", "Control" }, "x", identity)
  luaunit.assertEquals(cs_x.key_label, "C-X")
  luaunit.assertEquals(cs_x.sort_key, "x3")

  local shift_space = Bind.new({ "Shift" }, " ", identity)
  luaunit.assertEquals(shift_space.key_label, "S-SPC")
  luaunit.assertEquals(shift_space.sort_key, "z9 2")

  local sc_tab = Bind.new({ "Shift", "Control" }, "Tab", identity)
  luaunit.assertEquals(sc_tab.key_label, "SC-Tab")
  luaunit.assertEquals(sc_tab.sort_key, "z9tab3")

  local super_sac_lt = Bind.new(
    { "Mod4", "Mod1", "Control", "Shift" },
    "<",
    identity
  )
  luaunit.assertEquals(super_sac_lt.key_label, "SCA-<")
  luaunit.assertEquals(super_sac_lt.sort_key, "z9<3")
end

function TestWhichKeysBind:testDetails()
  local description = Bind.new(
    {},
    "a",
    identity,
    { description = "cook-dinner" }
  )
  luaunit.assertEquals(description.action_label, "cook-dinner")

  local color = Bind.new(
    {},
    "a",
    identity,
    { which_key_colors = which_key_theme.sticky }
  )
  luaunit.assertEquals(color.colors, which_key_theme.sticky)

  local hidden = Bind.new({}, "a", identity, { which_key_hidden = true })
  luaunit.assertEquals(hidden.is_hidden, true)

  local sticky = Bind.new({}, "a", identity, { which_key_sticky = true })
  luaunit.assertEquals(sticky.is_sticky, true)
end

function TestWhichKeysBind:testSticky()
  local sticky = Bind.new(
    {},
    "a",
    identity,
    { description = "@menu", which_key_sticky = true }
  )
  luaunit.assertEquals(sticky.is_sticky, true)
  luaunit.assertEquals(sticky.action_label, "@menu")
  luaunit.assertEquals(sticky.colors, which_key_theme.sticky)
end

return TestWhichKeysBind
