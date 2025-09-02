local opt = vim.opt
local g = vim.g

g.mapleader = " "
g.maplocalleader = "\\"

opt.termguicolors = true

-- Interaction options
opt.timeoutlen = 400
opt.updatetime = 1000
opt.mouse = "" -- fuck off

-- Scrolling options
opt.scrolloff = 10
opt.sidescrolloff = 20

-- Line number options
opt.number = true

-- Wrapping options
opt.wrap = true
opt.breakindent = true

-- Tab options
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2

-- Show hidden characters
opt.list = true
opt.listchars = "tab:→ ,nbsp:•"

-- Search options
opt.ignorecase = true
opt.smartcase = true

-- Load modelines from files (e.g. "vim: foo=bar")
opt.modeline = true

-- Split options
opt.splitbelow = true
opt.splitright = true

-- Nicer characters in "hole" areas of diffs and for folds.
-- NOTE: theme.lua will set a different FG color to not make the diff character look
-- terrible.
opt.fillchars = [[diff:╱,fold: ,foldopen:,foldsep: ,foldclose:]]

-- Use ripgrep for :grep.
opt.grepprg = "rg --vimgrep --no-heading --smart-case"
opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"

-- Set terminal title
opt.title = true

-- Better diff options
opt.diffopt = [[internal,filler,closeoff,linematch:50]]

-- Undo and swap options
opt.undofile = true
