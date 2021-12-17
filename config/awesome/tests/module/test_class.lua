local luaunit = require "luaunit"
local class = require "module.class"

local TestClass = {}

function TestClass:testInitialize()
  local Dog = class()

  function Dog:initialize(name, age)
    self.name = name
    self.age = age
    self.status = "good"
  end

  function Dog:introduction()
    return "I am "
      .. self.name
      .. " and I am a "
      .. self.status
      .. " dog of "
      .. self.age
      .. " years."
  end

  local fido = Dog.new("Fido", 9)
  luaunit.assertEquals(fido.name, "Fido")
  luaunit.assertEquals(
    fido:introduction(),
    "I am Fido and I am a good dog of 9 years."
  )
end

function TestClass:testNoInitializer()
  local Dog = class()
  -- Arguments to new are ignored when there is no initializer defined
  local fido = Dog.new("Fido", 9)
  luaunit.assertEquals(fido.name, nil)
end

return TestClass
