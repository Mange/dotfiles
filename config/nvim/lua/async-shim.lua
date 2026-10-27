-- Based on https://github.com/LazyVim/LazyVim/issues/7130#issuecomment-4637237326
-- Solves a problem with UFO having its own async plugin, which conflicts with other
-- plugins named "async".
---@module "plugins.nvim-ufo.async-shim"

local DEBUG = false

local M = {}

---@param msg string
local function log(msg)
  print("[async-shim] " .. msg)
end

local function get_lua_caller()
  -- skip 3 known levels: get_lua_caller, is_ufo_caller, metamethod
  for level = 4, 10 do
    local info = debug.getinfo(level, "S")
    if not info then
      break
    end
    local src = info.source or ""
    if src ~= "=[C]" and src ~= "" then
      return src
    end
  end
  return ""
end

function M.install()
  local lazy_config = require "lazy.core.config"

  local ufo_dir = lazy_config.plugins["nvim-ufo"].dir
  local promise_async_dir = lazy_config.plugins["promise-async"].dir

  local ufo_async = dofile(promise_async_dir .. "/lua/async.lua")
  assert(ufo_async, "failed to load promise-async/lua/async.lua via dofile")

  local other_async =
    dofile(lazy_config.plugins["async.nvim"].dir .. "/lua/async.lua")
  assert(other_async, "failed to load async.nvim/lua/async.lua via dofile")

  if DEBUG then
    log("installing proxy (ufo_dir=" .. ufo_dir .. ")")
  end

  local function is_ufo_caller()
    local caller = get_lua_caller()
    local is_ufo = caller:find(ufo_dir, 1, true) ~= nil
      or caller:find(promise_async_dir, 1, true) ~= nil

    if DEBUG then
      log(
        ("caller=%s -> %s"):format(
          caller:match "[^/]+/[^/]+/[^/]+$" or caller,
          is_ufo and "promise-async" or "async.nvim"
        )
      )
    end

    return is_ufo
  end

  package.loaded["async"] = setmetatable({}, {
    __index = function(_, key)
      return is_ufo_caller() and ufo_async[key] or other_async[key]
    end,
    __call = function(_, ...)
      return is_ufo_caller() and ufo_async(...) or other_async(...)
    end,
  })
end

return M
