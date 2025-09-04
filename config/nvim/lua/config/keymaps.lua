--
--                            ██████  ██████ ░░            █████
--      ██████████   ██████  ░██░░░██░██░░░██ ██ ███████  ██░░░██  ██████
--     ░░██░░██░░██ ░░░░░░██ ░██  ░██░██  ░██░██░░██░░░██░██  ░██ ██░░░░
--      ░██ ░██ ░██  ███████ ░██████ ░██████ ░██ ░██  ░██░░██████░░█████
--      ░██ ░██ ░██ ██░░░░██ ░██░░░  ░██░░░  ░██ ░██  ░██ ░░░░░██ ░░░░░██
--      ███ ░██ ░██░░████████░██     ░██     ░██ ███  ░██  █████  ██████
--     ░░░  ░░  ░░  ░░░░░░░░ ░░      ░░      ░░ ░░░   ░░  ░░░░░  ░░░░░░
--
local utils = require "mange.utils"
local wk = require "which-key"
local Snacks = require "snacks"

local function call(name, methods, ...)
  local args = { ... }
  return function()
    local mod = require(name)
    if type(methods) == "string" then
      methods = { methods }
    end

    for _, method in ipairs(methods) do
      mod = mod[method]
    end

    return mod(table.unpack(args))
  end
end

--
-- Actions
--
local actions = {
  reload_mappings = function()
    require("plenary.reload").reload_module "config.keymaps"
    require "config.keymaps"
  end,

  format_buf = function()
    require("conform").format { async = true, lsp_fallback = true }
  end,

  set_search_word = function()
    local word = vim.fn.expand "<cword>"
    utils.set_search_word(word)
  end,

  telescope_cword = function()
    local word = vim.fn.expand "<cword>"
    utils.set_search_word(word)
    require("telescope.builtin").grep_string {
      search = "\\b" .. utils.escape_regexp(word) .. "\\b",
      use_regex = true,
    }
  end,

  telescope_cWORD = function()
    local word = vim.fn.expand "<cWORD>"
    utils.set_search(word)
    require("telescope.builtin").grep_string {
      search = word,
      use_regex = false,
    }
  end,

  telescope_todos = function()
    local words = { "TODO", "FIXME" }
    local vim_search = "\\<\\(" .. vim.fn.join(words, "\\|") .. "\\)\\>"
    local grep_search = "\\b(" .. vim.fn.join(words, "|") .. ")\\b"
    vim.fn.setreg("/", vim_search)
    require("telescope.builtin").grep_string {
      search = grep_search,
      use_regex = true,
    }
  end,

  telescope_sibling_files = function()
    require("telescope.builtin").find_files(
      require("telescope.themes").get_dropdown {
        previewer = false,
        cwd = require("telescope.utils").buffer_dir(),
      }
    )
  end,

  -- Just using :%bd will not work in all cases; it will try to delete a few
  -- unnamed buffers that are modified, which will make it stop with an error. I
  -- don't care about unlisted buffers, just the listed ones. (These are usually
  -- floating windows' buffers from autocompletions and other similar plugins)
  --
  -- This function will only delete all buffers that are loaded, listed, and not
  -- modified and leave the rest alone.
  delete_all_buffers = function()
    local buffers = vim.tbl_filter(function(buf)
      return vim.api.nvim_buf_is_loaded(buf)
        and vim.bo[buf].buflisted
        and not vim.bo[buf].modified
    end, vim.api.nvim_list_bufs())

    for _, buf in ipairs(buffers) do
      vim.cmd(string.format("bd %d", buf))
    end
  end,

  focus_floating_win = function()
    local float = vim.api.nvim_get_current_win()
    if vim.api.nvim_win_get_config(float).relative ~= "" then
      -- Already in a floating window
      return
    end

    -- Find the next non-floating window
    local wins = vim.api.nvim_tabpage_list_wins(0)
    for _, win in ipairs(wins) do
      local conf = vim.api.nvim_win_get_config(win)
      if conf.focusable and conf.relative ~= "" then
        vim.api.nvim_set_current_win(win)
        return
      end
    end
  end,

  into_base64 = function()
    local input = utils.get_selection()
    local encoded = vim.base64.encode(input)
    utils.replace_selection(encoded)
    utils.feed_escape()
  end,

  from_base64 = function()
    local input = utils.get_selection()
    local decoded = vim.base64.decode(input)
    utils.replace_selection(decoded)
    utils.feed_escape()
  end,
}

--
-- Clear unwanted mappings
--
-- I use this as a contextual action key for some filetypes.
vim.keymap.set("n", "Q", "", { expr = true })

--
-- Root keymaps
--
wk.add {
  { "<tab>", "za", desc = "Toggle fold" },
  -- Restore <C-i> after <tab> is taken. See :help tui-input
  { "<C-i>", "<C-i>", desc = "Jump forward", remap = false },

  { "<S-h>", "gT", desc = "Tab left" },
  { "<S-l>", "gt", desc = "Tab right" },

  { "<C-h>", "<C-w>h", desc = "Window left" },
  { "<C-j>", "<C-w>j", desc = "Window down" },
  { "<C-k>", "<C-w>k", desc = "Window up" },
  { "<C-l>", "<C-w>l", desc = "Window right" },

  { "-", "<cmd>Oil<CR>", desc = "Open file directory" },

  -- Asterisk * should only set the current search, not jump to the next match.
  { "*", actions.set_search_word, desc = "Search word under cursor" },

  { "<C-s>", ":silent! wall<cr>", desc = "Save all" },
  { "<C-s>", "<C-o>:silent! wall<cr>", desc = "Save all", mode = "i" },
  { "<C-c><C-c>", ":wq<CR>", desc = "Save and close" },
  { "<C-c><C-c>", "<C-o>:wq<CR>", desc = "Save and close", mode = "i" },

  -- Digraph (replaces C-k, which I use for LSP signature help in insert mode)
  { "<C-l>", "<C-k>", desc = "Enter digraph", mode = "i" },

  -- Moving things in visual mode
  { "<C-j>", ":m '>+1<CR>gv=gvzz", desc = "Move selection down", mode = "v" },
  { "<C-k>", ":m '<-2<CR>gv=gvzz", desc = "Move selection up", mode = "v" },
}

--
-- Command mode keymaps
--
wk.add {
  -- stylua: ignore start
  -- silent = false is required, or else the command line will not update to show the expansion.
  { "%%", "<C-R>=fnameescape(expand('%'))<cr>", desc = "Current file path", mode = "c", silent = false },
  { "$$", "<C-R>=fnameescape(expand('%:h'))<cr>", desc = "Current file dir", mode = "c", silent = false },
  { "^^", "<C-R>=fnameescape(expand('%:t'))<cr>", desc = "Current file basename", mode = "c", silent = false },
  -- stylua: ignore end
}

--
-- Neovide keymaps
--
if vim.g.neovide then
  wk.add {
    {
      "<C-+>",
      function()
        vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1
      end,
      mode = { "n", "v", "i" },
      desc = "Zoom in",
    },
    {
      "<C-->",
      function()
        vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1
      end,
      mode = { "n", "v", "i" },
      desc = "Zoom out",
    },
    {
      "<C-0>",
      function()
        vim.g.neovide_scale_factor = 1.0
      end,
      mode = { "n", "v", "i" },
      desc = "Zoom reset",
    },

    -- Replicate paste keys from Wezterm
    { "<C-S-c>", '"+y', mode = { "v" }, desc = "Copy to clipboard" },
    { "<C-S-v>", "<C-r>+", mode = { "i" }, desc = "Paste from clipboard" },
    { "<C-S-v>", '"+p', mode = { "n", "v" }, desc = "Paste from clipboard" },

    -- <C-z> in Neovide won't work. Open a terminal instead.
    { "<C-z>", Snacks.terminal, desc = "Toggle terminal" },
  }
end

--
-- Flash
--
wk.add {
  -- stylua: ignore start
  { "<cr>", call("flash", "jump"), desc = "Flash", mode = { "n", "x", "o" } },
  { "<bs>", call("flash", "treesitter"), desc = "Flash Treesitter", mode = { "n", "x", "o" } },
  { "R", call("flash", "remote"), desc = "Remote Flash", mode = { "o" } },
  { "s", call("flash", "treesitter_search"), desc = "Treesitter Search", mode = { "x", "o" } },
  -- stylua: ignore end
}

--
-- Substitute
--
wk.add {
  -- stylua: ignore start
  -- n mode
  { "s", call("substitute", "operator"), noremap = true, desc = "Substitute", group = "substitute" },
  { "ss", call("substitute", "line"), noremap = true, desc = "Line" },
  { "S", call("substitute", "eol"), noremap = true, desc = "End of line" },
  { "sx", call("substitute.exchange", "operator"), noremap = true, desc = "Exchange", group = "exchange" },
  { "sxx", call("substitute.exchange", "line"), noremap = true, desc = "Line" },
  { "sxc", call("substitute.exchange", "cancel"), noremap = true, desc = "Cancel" },

  -- x mode
  { "s", call("substitute", "visual"), mode = "x", noremap = true, desc = "Substitute", group = "substitute" },
  { "X", call("substitute.exchange", "visual"), mode = "x", noremap = true, desc = "Exchange" },
  -- stylua: ignore end
}

--
-- Coerce
--
wk.add {
  -- NOTE: This does not integrate cleanly with "c", as that normally starts operator pending mode.
  -- Hence these groups of keybinds do not appear when just pressing "c". Adding the binds inside
  -- of the operator pending mode breaks the functionality, so that is not a solution either.
  { "cr", group = "coerce" },
  { "crr", "<cmd>TextCaseOpenTelescope<CR>", desc = "Telescope" },
}

--
-- Navigation
--
wk.add {
  -- stylua: ignore start
  { "[t", call("neotest", { "jump", "prev" }), desc = "Previous test" },
  { "]t", call("neotest", { "jump", "next" }), desc = "Next test" },
  { "[T", call("neotest", { "jump", "prev" }, { status = "failed" }), desc = "Previous failing test" },
  { "]T", call("neotest", { "jump", "next" }, { status = "failed" }), desc = "Next failing test" },

  { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Previous reference" },
  { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Next reference" },

  { "[q", call("trouble", "previous", { mode = "quickfix", jump = true }), desc = "Previous quickfix" },
  { "]q", call("trouble", "next", { mode = "quickfix", jump = true }), desc = "Next quickfix" },

  { "[c", call("gitsigns.actions", "prev_hunk"), cond = not vim.o.diff, desc = "Previous change" },
  { "]c", call("gitsigns.actions", "next_hunk"), cond = not vim.o.diff, desc = "Next change" },

  { "[e", vim.diagnostic.goto_prev, desc = "Previous diagnostic" },
  { "]e", vim.diagnostic.goto_next, desc = "Next diagnostic" },
  -- stylua: ignore end
}

--
-- Copilot
--
wk.add {
  -- stylua: ignore start
  { "<C-a>", 'copilot#Accept("<CR>")', mode = "i", expr = true, desc = "Copilot: Accept" },
  { "<M-Right>", "<Plug>(copilot-accept-word)", mode = "i", desc = "Copilot: Accept word" },
  { "<M-L>", "<Plug>(copilot-accept-word)", mode = "i", desc = "Copilot: Accept word" },
  { "<M-Down>", "<Plug>(copilot-accept-line)", mode = "i", desc = "Copilot: Accept line" },
  { "<M-J>", "<Plug>(copilot-accept-line)", mode = "i", desc = "Copilot: Accept line" },
  { "<M-Up>", "<Plug>(copilot-next)", mode = "i", desc = "Copilot: Next" },
  { "<M-K>", "<Plug>(copilot-next)", mode = "i", desc = "Copilot: Next" },
  -- stylua: ignore end
}

--
-- Visual Leader chords
--
wk.add {
  -- stylua: ignore start
  { "<leader>a", ":CodeCompanionChat Toggle<cr>", desc = "AI chat", mode = "v"},
  { "<leader>A", "<cmd>CodeCompanionChat Add<cr>", desc = "AI add to chat", mode = "v" },
  -- stylua: ignore end

  { "<leader>f", group = "from", mode = "v" },
  { "<leader>f6", actions.from_base64, desc = "base64", mode = "v" },

  { "<leader>i", group = "into", mode = "v" },
  { "<leader>i6", actions.into_base64, desc = "base64", mode = "v" },

  { "<leader>s", group = "sort", mode = "v" },
  { "<leader>ss", ":'<,'>sort<cr>", desc = "Normal", mode = "v" },
  { "<leader>sS", ":'<,'>sort!<cr>", desc = "Reverse", mode = "v" },
  { "<leader>sn", ":'<,'>sort n<cr>", desc = "Numeric", mode = "v" },
  { "<leader>sN", ":'<,'>sort! n<cr>", desc = "Numeric reverse", mode = "v" },
  { "<leader>su", ":'<,'>sort u<cr>", desc = "Unique", mode = "v" },
  { "<leader>sU", ":'<,'>sort! u<cr>", desc = "Unique reverse", mode = "v" },

  { "<leader>x", group = "extract", mode = "v" },
  {
    "<leader>xf",
    call("genghis", "moveSelectionToNewFile"),
    desc = "…to file",
    mode = "v",
  },
}

--
-- Leader chords: root
--
wk.add {
  -- stylua: ignore start
  { "<leader>:", "<cmd>Telescope commands<cr>", desc = "Commands" },
  { "<leader>/", "<cmd>nohl<cr>", desc = "nohl" },
  { "<leader>N", "<cmd>Telescope resume<cr>", desc = "Telescope resume" },

  { "<leader>q", call("fidget", {"notification", "clear"}), desc = "Close notifications" },

  { "<leader>j", call("treesj", "split"), desc = "Split line" },
  { "<leader>k", function()
    if vim.bo.ft == "rust" then
      vim.cmd.RustLsp "joinLines"
    else
      require("treesj").join()
    end
  end, desc = "Join line" },
  -- stylua: ignore end
}

--
-- Leader chords: buffers
--
wk.add {
  { "<leader>b", group = "buffers" },

  { "<leader>bb", "<cmd>Telescope buffers<cr>", desc = "Search buffers" },
  { "<leader>by", ":%y+<cr>", desc = "Yank to clipboard" },
  { "<leader>bD", actions.delete_all_buffers, desc = "Delete all buffers" },
  { "<leader>bd", ":bd<cr>", desc = "Delete buffer" },
  { "<leader>bk", Snacks.bufdelete, desc = "Kill buffer" },
  { "<leader>bf", "<cmd>Telescope filetypes<cr>", desc = "Set filetype" },
  { "<leader>bl", ":b #<cr>", desc = "Goto last" },
  { "<leader>bn", "<cmd>enew<cr>", desc = "New" },
}

--
-- Leader chords: file
--
wk.add {
  { "<leader>f", group = "file" },

  { "<leader>ff", actions.telescope_sibling_files, desc = "Find sibling" },
  { "<leader>fr", call("genghis", "renameFile"), desc = "Rename" },
  { "<leader>fD", call("genghis", "trashFile"), desc = "Delete" },
  { "<leader>fm", call("genghis", "moveAndRenameFile"), desc = "Move" },
  { "<leader>fc", call("genghis", "duplicateFile"), desc = "Copy" },
  { "<leader>fx", call("genghis", "chmodx"), desc = "chmod +x" },
  { "<leader>fh", "<cmd>Telescope oldfiles<cr>", desc = "History" },
  { "<leader>fs", "<cmd>write<cr>", desc = "Save" },
  { "<leader>fa", "<cmd>silent! wall<cr>", desc = "Save all" },
}

--
-- Leader chords: git
--
wk.add {
  { "<leader>g", group = "git" },

  { "<leader>gg", "<cmd>Neogit<cr>", desc = "Status" },
  { "<leader>go", Snacks.gitbrowse, desc = "Open in browser" },
  { "<leader>gc", call("neogit", "open", { "commit" }), desc = "Commit" },

  { "<leader>ga", "<cmd>Gitsigns stage_buffer<cr>", desc = "Stage buffer" },
  { "<leader>gs", "<cmd>Gitsigns stage_hunk<cr>", desc = "Stage hunk" },
  { "<leader>gS", "<cmd>Gitsigns undo_stage_hunk<cr>", desc = "Unstage hunk" },
  { "<leader>gu", "<cmd>Gitsigns reset_hunk<cr>", desc = "Undo hunk" },
  { "<leader>gp", "<cmd>Gitsigns preview_hunk<cr>", desc = "Preview hunk" },

  -- stylua: ignore start
  { "<leader>gb", "<cmd>Gitsigns blame_line<cr>", desc = "Blame line" },
  { "<leader>gB", "<cmd>Gitsigns blame_line true<cr>", desc = "Blame line (full)" },
  -- stylua: ignore end

  { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
  { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Working diff" },
  { "<leader>gm", "<cmd>DiffviewOpen master<cr>", desc = "Master diff" },
  {
    "<leader>gM",
    "<cmd>DiffviewOpen main<cr>",
    desc = "Main diff",
    icon = "󰟮",
  },
}

--
-- Leader chords: help/vim
--
wk.add {
  { "<leader>h", group = "help/vim" },

  { "<leader>hh", "<cmd>Telescope help_tags<cr>", desc = "Help" },
  { "<leader>h?", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
  { "<leader>hk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
  { "<leader>hH", "<cmd>Telescope highlights<cr>", desc = "Highlights" },
  { "<leader>hb", "<cmd>Telescope marks<cr>", desc = "Bookmarks" },
  { "<leader>hm", "<cmd>Telescope man_pages<cr>", desc = "Man pages" },
  { "<leader>ho", "<cmd>Telescope vim_options<cr>", desc = "Options" },
  { "<leader>hc", "<cmd>Telescope colorscheme<cr>", desc = "Colorschemes" },
  { "<leader>hc", "<cmd>Telescope colorscheme<cr>", desc = "Colorschemes" },
  { "<leader>hn", "<cmd>Fidget history<cr>", desc = "Notification history" },
  {
    "<leader>hN",
    function()
      Snacks.win {
        file = vim.api.nvim_get_runtime_file("doc/news.txt", false)[1],
        width = 0.6,
        height = 0.6,
        wo = {
          spell = false,
          wrap = false,
          signcolumn = "yes",
          statuscolumn = " ",
          conceallevel = 3,
        },
      }
    end,
    desc = "Neovim News",
  },

  { "<leader>hp", group = "packages" },
  { "<leader>hpp", "<cmd>Lazy<cr>", desc = "Packages" },
  { "<leader>hpc", "<cmd>Lazy check<cr>", desc = "Check" },
  { "<leader>hpu", "<cmd>Lazy update<cr>", desc = "Update" },
  { "<leader>hpi", "<cmd>Lazy install<cr>", desc = "Install" },
  { "<leader>hps", "<cmd>Lazy sync<cr>", desc = "Sync" },

  { "<leader>hr", group = "reload" },
  { "<leader>hrr", "<cmd>Telescope reloader<cr>", desc = "Reload module" },
  { "<leader>hrm", actions.reload_mappings, desc = "Reload keymaps" },
}

--
-- Leader chords: notes
--
wk.add {
  { "<leader>n", group = "notes" },
  { "<leader>nn", "<cmd>SplitOrFocus notes.local<cr>", desc = "Local notes" },
  {
    "<leader>nf",
    call("snacks", "win", {
      file = "notes.local",
      width = 0.6,
      height = 0.6,
      backdrop = 99,
      bo = { modifiable = true },
    }),
    desc = "Local notes (float)",
  },
}

--
-- Leader chords: code
--
wk.add {
  { "<leader>c", group = "code" },

  -- stylua: ignore start
  { "<leader>c=", actions.format_buf, desc = "Format" },
  { "<leader>cr", vim.lsp.buf.rename, desc = "Rename" },

  { "<leader>cd", "<cmd>Trouble diagnostics focus=true filter.buf=0<cr>", desc = "Diagnostics (buffer)" },
  { "<leader>cD", "<cmd>Trouble diagnostics<cr>", desc = "Diagnostics (all)" },
  { "<leader>cs", "<cmd>Trouble lsp_document_symbols toggle focus=true pinned=true vim.position=right<cr>", desc = "Symbols" },
  -- stylua: ignore end

  -- stylua: ignore start
  { "<leader>cg", group = "goto" },
  { "<leader>cgg", "<cmd>Trouble lsp focus=true auto_refresh=false<cr>", desc = "All" },
  { "<leader>cgd", "<cmd>Trouble lsp_definitions focus=true auto_refresh=false<cr>", desc = "Definitions" },
  { "<leader>cgr", "<cmd>Trouble lsp_references focus=true auto_refresh=false<cr>", desc = "References" },
  { "<leader>cgi", "<cmd>Trouble lsp_implementations focus=true auto_refresh=false<cr>", desc = "Implementations" },
  { "<leader>cgt", "<cmd>Trouble lsp_type_definitions focus=true auto_refresh=false<cr>", desc = "Type definitions" },
  { "<leader>cg<", "<cmd>Trouble lsp_incoming_calls focus=true auto_refresh=false pinned=true vim.position=right<cr>", desc = "Incoming calls" },
  { "<leader>cg>", "<cmd>Trouble lsp_outgoing_calls focus=true auto_refresh=false pinned=true vim.position=right<cr>", desc = "Outgoing calls" },
  -- stylua: ignore end
}

--
-- Leader chords: project
--
wk.add {
  -- stylua: ignore start
  { "<leader>p", group = "project" },

  { "<leader>pd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
  { "<leader>pf", "<cmd>Telescope find_files<cr>", desc = "Find file" },
  { "<leader>pm", "<cmd>Telescope git_status<cr>", desc = "Modified files" },
  { "<leader>ps", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Symbols" },
  { "<leader>pT", actions.telescope_todos, desc = "TODOs" },

  { "<leader>pt", Snacks.terminal, desc = "Terminal" },

  { "<leader>pi", "<cmd>SplitOrFocus .git/local.lua<cr>", desc = "Project vimrc (lua)" },
  { "<leader>pI", "<cmd>SplitOrFocus .git/local.vim<cr>", desc = "Project vimrc (vimscript)" },
  -- stylua: ignore end
}

--
-- Leader chords: search
--
wk.add {
  -- stylua: ignore start
  { "<leader>s", group = "search" },

  { "<leader>sw", actions.telescope_cword, desc = "Search for word" },
  { "<leader>sW", actions.telescope_cWORD, desc = "Search for WORD" },
  { "<leader>st", actions.telescope_todos, desc = "TODOs" },

  { "<leader>ss", "<cmd>Telescope live_grep<cr>", desc = "Search for text" },
  { "<leader>so", "<cmd>Telescope live_grep grep_open_files=true<cr>", desc = "Text in open files" },
  { "<leader>sf", "<cmd>Telescope find_files<cr>", desc = "Files" },
  { "<leader>sh", "<cmd>Telescope search_history<cr>", desc = "Search history" },

  { "<leader>sj", "<cmd>cnewer<cr>", desc = "Newer quickfix" },
  { "<leader>sk", "<cmd>colder<cr>", desc = "Older quickfix" },
  -- stylua: ignore end
}

--
-- Leader chords: test
--
wk.add {
  { "<leader>T", group = "test" },

  -- stylua: ignore start
  { "<leader>Tt", call("neotest", { "run", "run" }), desc = "Nearest" },
  { "<leader>Ta", call("neotest", { "run", "run" }, { suite = true }), desc = "All" },
  { "<leader>TA", call("neotest", { "run", "attach" }), desc = "Attach" },
  { "<leader>Tl", call("neotest", { "run", "run_last" }), desc = "Last" },
  { "<leader>Ts", call("neotest", { "run", "stop" }), desc = "Stop" },
  { "<leader>Tf", function() require("neotest").run.run(vim.fn.expand "%") end, desc = "File" },
  { "<leader>Td", function() require("neotest").run.run(vim.uv.cwd()) end, desc = "CWD" },

  { "<leader>To", call("neotest", { "output", "open" }, { enter = true, auto_close = true }), desc = "Show output" },
  { "<leader>TO", call("neotest", { "output_panel", "toggle" }), desc = "Toggle output panel" },
  -- stylua: ignore end
}

--
-- Leader chords: toggle
--
wk.add {
  { "<leader>t", group = "toggle" },

  -- Not actually a *toggle*, more like a "Toggle off". Just pressing n/N
  -- will enable the highlights again anyway.
  { "<leader>th", "<cmd>nohl<cr>", desc = "Disable search highlights" },
}
-- Toggles (through Snacks)
Snacks.toggle.option("list", { name = "Listchars" }):map "<leader>tl"
Snacks.toggle.option("number", { name = "Number" }):map "<leader>tn"
Snacks.toggle.option("spell", { name = "Spelling" }):map "<leader>ts"
Snacks.toggle.option("wrap", { name = "Wrap" }):map "<leader>tw"
Snacks.toggle.inlay_hints():map "<leader>ti"
Snacks.toggle.diagnostics():map "<leader>td"
Snacks.toggle.treesitter():map "<leader>tT"
Snacks.toggle
  .option("relativenumber", { name = "Relative number" })
  :map "<leader>tN"

Snacks.toggle
  .option("conceallevel", {
    name = "Conceal",
    off = 0,
    on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2,
  })
  :map "<leader>t_"

Snacks.toggle
  .option("background", { off = "light", on = "dark", name = "Dark Background" })
  :map "<leader>tD"

Snacks.toggle
  .new({
    name = "Cursorline",
    get = function()
      return require("mange.cursorline").enabled
    end,
    set = function(state)
      require("mange.cursorline").toggle(state)
    end,
  })
  :map "<leader>tc"

Snacks.toggle
  .new({
    name = "Context",
    get = function()
      return require("treesitter-context").enabled()
    end,
    set = function(state)
      if state == true then
        require("treesitter-context").enable()
      elseif state == false then
        require("treesitter-context").disable()
      else
        require("treesitter-context").toggle(state)
      end
    end,
  })
  :map "<leader>tx"

Snacks.toggle
  .new({
    name = "Autoformat (buffer)",
    get = function()
      return require("mange.formatting").buffer_enabled()
    end,
    set = function(state)
      require("mange.formatting").toggle_buffer(state)
    end,
  })
  :map "<leader>tf"

Snacks.toggle
  .new({
    name = "Autoformat (global)",
    get = function()
      return require("mange.formatting").globally_enabled()
    end,
    set = function(state)
      require("mange.formatting").toggle_global(state)
    end,
  })
  :map "<leader>tF"

Snacks.toggle
  .new({
    name = "Highlight colors",
    get = function()
      return require("nvim-highlight-colors").is_active()
    end,
    set = function(state)
      if state then
        require("nvim-highlight-colors").turnOn()
      else
        require("nvim-highlight-colors").turnOff()
      end
    end,
  })
  :map "<leader>tC"

Snacks.toggle
  .new({
    name = "Signs",
    get = function()
      return require("gitsigns.config").config.signcolumn
    end,
    set = function(state)
      require("gitsigns").toggle_signs(state)
    end,
  })
  :map "<leader>tgs"

Snacks.toggle
  .new({
    name = "Show deleted",
    get = function()
      return require("gitsigns.config").config.show_deleted
    end,
    set = function(state)
      require("gitsigns").toggle_deleted(state)
    end,
  })
  :map "<leader>tgd"

Snacks.toggle
  .new({
    name = "Line blame",
    get = function()
      return require("gitsigns.config").config.current_line_blame
    end,
    set = function(state)
      require("gitsigns").toggle_current_line_blame(state)
    end,
  })
  :map "<leader>tgl"

--
-- Leader chords: open
--
wk.add {
  { "<leader>o", group = "open" },

  { "<leader>oa", "<cmd>CodeCompanionChat Toggle<cr>", desc = "AI chat" },
  { "<leader>oA", "<cmd>CodeCompanionActions<cr>", desc = "AI actions" },
  { "<leader>op", "<cmd>CccPick<cr>", desc = "Color picker" },

  {
    "<leader>od",
    "<cmd>Trouble diagnostics toggle focus=true<cr>",
    desc = "Diagnostics",
  },
  {
    "<leader>oq",
    "<cmd>Trouble quickfix toggle focus=true<cr>",
    desc = "Quickfix list",
  },

  {
    "<leader>ot",
    call("neotest", { "summary", "toggle " }),
    desc = "Test summary",
  },
}

--
-- Leader chords: window
--
wk.add {
  { "<leader>w", group = "window" },

  { "<leader>wh", "<C-w>h", desc = "Left" },
  { "<leader>wj", "<C-w>j", desc = "Down" },
  { "<leader>wk", "<C-w>k", desc = "Up" },
  { "<leader>wl", "<C-w>l", desc = "Right" },

  { "<leader>ws", "<C-w>s", desc = "Split hostizontal" },
  { "<leader>wv", "<C-w>v", desc = "Split vertical" },

  { "<leader>wq", "<C-w>q", desc = "Close" },
  { "<leader>wo", "<C-w>o", desc = "Only this" },

  { "<leader>wf", actions.focus_floating_win, desc = "Focus float" },
}

--
-- Text objects
--
wk.add {
  {
    "ih",
    call("gitsigns.actions", "select_hunk"),
    desc = "Inner hunk",
    mode = { "o", "x" },
  },
}

--
-- LSP mappings
--
utils.on_lsp_attach(function(_, bufnr)
  local modifiable = vim.bo[bufnr].modifiable

  local function buffer_map(opts)
    local lhs = opts[1]
    local desc = opts[2]
    local rhs = opts[3]

    opts[1] = nil
    opts[2] = nil
    opts[3] = nil

    wk.add {
      vim.tbl_extend("force", { lhs, rhs, desc = desc, buffer = bufnr }, opts),
    }
  end

  buffer_map { "<leader><cr>", "Code action", vim.lsp.buf.code_action }
  buffer_map {
    "<leader><cr>",
    "Code action",
    vim.lsp.buf.range_code_action,
    mode = "v",
  }

  -- stylua: ignore start
  buffer_map { "=", "Format", actions.format_buf, mode = "v", cond = modifiable }
  buffer_map { "<leader>=", "Format", actions.format_buf, mode = "v", cond = modifiable }
  -- stylua: ignore end

  buffer_map { "K", "Hover documentation", vim.lsp.buf.hover }

  buffer_map { "gK", "Signature help", utils.show_signature_help }
  buffer_map {
    "<C-k>",
    "Signature help",
    function()
      utils.show_signature_help { force = true }
    end,
    mode = "i",
  }

  buffer_map {
    "gd",
    "Line diagnostics",
    function()
      utils.show_diagnostic_float { force = true, scope = "line" }
    end,
  }

  buffer_map {
    "<C-]>",
    "LSP definitions",
    "<cmd>Trouble lsp_definitions focus=true<cr>",
  }
end, {
  group = vim.api.nvim_create_augroup("MangeLspKeymaps", { clear = true }),
})
