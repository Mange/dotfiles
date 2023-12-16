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

local function bootstrap_plugin_system()
  local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable", -- latest stable release
      lazypath,
    }
  end
  vim.opt.rtp:prepend(lazypath)
end

local function load_plugins()
  -- Setup leader key to space. This must happen before lazy.nvim is loaded.
  vim.g.mapleader = " "
  vim.g.maplocalleader = "\\"

  require("lazy").setup("plugins", {
    dev = { path = "~/Projects" },
    install = {
      colorscheme = { "catppuccin" },
    },
    diff = { cmd = "diffview.nvim" },
    checker = {
      enabled = false,
      concurrency = 1, -- To check very slowly
      frequency = 60 * 60 * 24, -- Check once a day
    },
    rtp = {
      disabled_plugins = {
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  })
end

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

bootstrap_plugin_system()
require "mange.options"

load_plugins()
require "mange.theme"
require "mange.filetypes"
require "mange.commands"
require "mange.autocommands"

require("mange.mappings").setup()
require("mange.cursorline").setup()
require("mange.yank_highlight").setup()
require("mange.vimdiff").setup()
