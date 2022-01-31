--
--                            ██
--                           ░░
--                   ██    ██ ██ ██████████  ██████  █████
--                  ░██   ░██░██░░██░░██░░██░░██░░█ ██░░░██
--                  ░░██ ░██ ░██ ░██ ░██ ░██ ░██ ░ ░██  ░░
--                   ░░████  ░██ ░██ ░██ ░██ ░██   ░██   ██
--                    ░░██   ░██ ███ ░██ ░██░███   ░░█████
--                     ░░    ░░ ░░░  ░░  ░░ ░░░     ░░░░░
--
--
-- This file is written such that if it's opened on a new machine, then packer
-- will be installed first and after that is completed then the real config
-- is loaded.
-- For this to work, all config is wrapped in a function.

--- {{{ Lua imports
local cmd = vim.cmd
local fn = vim.fn
--- }}}
--- {{{ Require helper
-- Require and execute passed function with the loaded module, if it
-- successfully loaded.
_G.if_require = function(module, block, errblock)
  local ok, mod = pcall(require, module)
  if ok then
    return block(mod)
  elseif errblock then
    return errblock(mod)
  else
    vim.api.nvim_err_writeln("Failed to load " .. module .. ": " .. mod)
    return nil
  end
end
--- }}}

local function load_plugins()
  require "plugins"
  --- Automatically compile plugins file when edited.
  cmd [[
    augroup packer_aus
      au!
      au BufWritePost */config/lua/plugins.lua source <afile> | PackerCompile | echo "Refreshed plugins"
    augroup END
  ]]
end

_G.load_config = function()
  require "mange.options"

  require("mange.theme").setup()
  require("mange.mappings").setup()

  require("mange.cursorline").setup()
  require("mange.yank_highlight").setup()
  require("mange.vimdiff").setup()

  require "mange.autocommands"
end

--- {{{ Startup (and bootstapping)
-- Bootstrap Packer if not installed already
do
  local install_path = fn.stdpath "data"
    .. "/site/pack/packer/start/packer.nvim"
  if fn.isdirectory(install_path) == 0 then
    fn.system {
      "git",
      "clone",
      "https://github.com/wbthomason/packer.nvim",
      install_path,
    }
    cmd "packadd packer.nvim"
    load_plugins()
    require("packer").sync()
    cmd "autocmd User PackerComplete ++once lua load_config()"
  else
    load_plugins()
    load_config()
  end
end
--- }}}
