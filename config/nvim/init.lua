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

---@diagnostic disable-next-line: deprecated
table.unpack = table.unpack or unpack

require "config.options"
require "core.lazy"
require "core.lsp"
require "core.vimdiff"

require "config.keymaps"
require "config.filetypes"
require "config.commands"
require "config.autocommands"

-- My own mini plugins
require("mange.cursorline").setup()
