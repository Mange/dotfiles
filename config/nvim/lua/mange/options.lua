local opt = vim.opt

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

-- When tabcompleting in cmdline, complete to the longest common string and
-- show the list. Then on the second tab press, complete to the first full
-- entry.
opt.wildmode = { "list:longest", "full" }

-- Nicer characters in "hole" areas of diffs and for folds.
-- NOTE: theme.lua will set a different FG color to not make the diff character look
-- terrible.
opt.fillchars = [[diff:╱,fold: ,foldopen:,foldsep: ,foldclose:]]

-- Use ripgrep for :grep.
opt.grepprg = "rg --vimgrep --no-heading --smart-case"
opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"

-- Set terminal title
opt.title = true
