local function class(super)
  local object = {}
  object.__index = object
  setmetatable(object, super)

  function object.new(...)
    local instance = setmetatable({}, object)
    if instance.initialize then
      instance:initialize(...)
    end
    return instance
  end

  return object
end

return class
