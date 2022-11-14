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

--
-- Lua imports
--
local cmd = vim.cmd
local fn = vim.fn

--
-- Require helper
--
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

_G.load_config = function()
  require "mange.options"

  require("mange.theme").setup()
  require("mange.mappings").setup()

  require("mange.cursorline").setup()
  require("mange.winbar").setup()
  require("mange.yank_highlight").setup()
  require("mange.vimdiff").setup()

  require "mange.filetypes"
  require "mange.autocommands"
end

--
-- Startup (and bootstapping)
--
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
    require "plugins"
    require("packer").sync()
    cmd "autocmd User PackerComplete ++once lua load_config()"
  else
    require "plugins"
    load_config()
  end
end
