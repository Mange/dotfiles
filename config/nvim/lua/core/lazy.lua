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
  require("lazy").setup({ import = "plugins" }, {
    dev = { path = "~/Projects" },
    install = {
      missing = true,
      colorscheme = { "catppuccin" },
    },
    diff = { cmd = "diffview.nvim" },
    checker = {
      enabled = false,
    },
    performance = {
      rtp = {
        disabled_plugins = {
          "netrwPlugin",
          "tarPlugin",
          "tohtml",
          "tutor",
          "zipPlugin",
        },
      },
    },
  })
end

bootstrap_plugin_system()
load_plugins()
