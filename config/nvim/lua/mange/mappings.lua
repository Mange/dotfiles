--
--                            ██████  ██████ ░░            █████
--      ██████████   ██████  ░██░░░██░██░░░██ ██ ███████  ██░░░██  ██████
--     ░░██░░██░░██ ░░░░░░██ ░██  ░██░██  ░██░██░░██░░░██░██  ░██ ██░░░░
--      ░██ ░██ ░██  ███████ ░██████ ░██████ ░██ ░██  ░██░░██████░░█████
--      ░██ ░██ ░██ ██░░░░██ ░██░░░  ░██░░░  ░██ ░██  ░██ ░░░░░██ ░░░░░██
--      ███ ░██ ░██░░████████░██     ░██     ░██ ███  ░██  █████  ██████
--     ░░░  ░░  ░░  ░░░░░░░░ ░░      ░░      ░░ ░░░   ░░  ░░░░░  ░░░░░░
--

--
-- Helpers
--
local g = vim.g
local api = vim.api
local utils = require "mange.utils"

local function map(mode, key, command, options)
  options = vim.tbl_extend("force", { noremap = true, silent = true }, options)
  local buffer = options.buffer
  options.buffer = nil

  if buffer then
    return api.nvim_buf_set_keymap(buffer, mode, key, command, options)
  else
    return api.nvim_set_keymap(mode, key, command, options)
  end
end

local function wk_register(...)
  local args = { ... }
  if_require("which-key", function(wk)
    return wk.register(unpack(args))
  end, function(_)
    api.nvim_err_writeln "WhichKeys not installed; cannot apply mappings!"
  end)
end

local function reload_mappings()
  require("plenary.reload").reload_module "mange.mappings"
  require("mange.mappings").setup()
end

--
-- Actions
--
local function telescope_cword()
  local word = vim.fn.expand "<cword>"
  utils.set_search_word(word)
  require("telescope.builtin").grep_string {
    search = "\\b" .. utils.escape_regexp(word) .. "\\b",
    use_regex = true,
  }
end

local function telescope_cWORD()
  local word = vim.fn.expand "<cWORD>"
  utils.set_search(word)
  require("telescope.builtin").grep_string {
    search = word,
    use_regex = false,
  }
end

local function telescope_todos()
  local words = { "TODO", "FIXME" }
  local vim_search = "\\<\\(" .. vim.fn.join(words, "\\|") .. "\\)\\>"
  local grep_search = "\\b(" .. vim.fn.join(words, "|") .. ")\\b"
  vim.fn.setreg("/", vim_search)
  require("telescope.builtin").grep_string {
    search = grep_search,
    use_regex = true,
  }
end

-- Just using :%bd will not work in all cases; it will try to delete a few
-- unnamed buffers that are modified, which will make it stop with an error. I
-- don't care about unlisted buffers, just the listed ones. (These are usually
-- floating windows' buffers from autocompletions and other similar plugins)
--
-- This function will only delete all buffers that are loaded and listed and
-- leave the rest alone.
local function delete_all_buffers()
  local buffers = vim.tbl_filter(function(buf)
    return vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted
  end, vim.api.nvim_list_bufs())

  for _, buf in ipairs(buffers) do
    vim.cmd(string.format("bd %d", buf))
  end
end

local function setup()
  --
  -- Root
  --
  -- Unmap Q
  -- I'll use it for context-sensitive actions depending on filetype
  map("", "Q", "", { expr = true })
  vim.keymap.set("n", "<tab>", "za", { desc = "Toggle fold" })
  -- Restore <C-i> after <tab> is taken. See :help tui-input
  vim.keymap.set(
    "n",
    "<C-i>",
    "<C-i>",
    { desc = "Jump forward", remap = false }
  )

  wk_register {
    -- Shift-H and Shift-L to switch tabs
    ["<S-h>"] = { "gT", "Tab left" },
    ["<S-l>"] = { "gt", "Tab right" },

    -- CTRL-<navigation> to move windows
    ["<C-h>"] = { "<C-w>h", "Window left" },
    ["<C-j>"] = { "<C-w>j", "Window down" },
    ["<C-k>"] = { "<C-w>k", "Window up" },
    ["<C-l>"] = { "<C-w>l", "Window right" },

    -- Open file browser in current file's directory
    ["-"] = {
      ':Telescope file_browser cwd=<C-R>=fnameescape(expand("%:p:h"))<cr><cr>',
      "Browse file directory",
    },

    -- Asterisk * should only set the current search, not jump to the next match.
    ["*"] = {
      ":let @/ = '\\<<C-R>=fnameescape(expand('<cword>'))<CR>\\>'<CR>",
      "Search word under cursor",
    },

    -- Next/previous quickfix
    ["]q"] = {
      function()
        require("trouble").next { skip_groups = true, jump = true }
      end,
      "Trouble next",
    },
    ["[q"] = {
      function()
        require("trouble").previous { skip_groups = true, jump = true }
      end,
      "Trouble previous",
    },

    ["<BS>"] = {
      function()
        vim.notify("Use <C-A> instead!", vim.log.levels.INFO)
      end,
      "Deprecated",
    },

    --
    -- Gitsigns
    --
    ["]c"] = {
      function()
        if vim.o.diff then
          vim.normal "]c"
        else
          require("gitsigns.actions").next_hunk()
        end
      end,
      "Next hunk",
    },
    ["[c"] = {
      function()
        if vim.o.diff then
          vim.normal "[c"
        else
          require("gitsigns.actions").prev_hunk()
        end
      end,
      "Previous hunk",
    },

    ["<C-s>"] = { ":silent! wall<cr>", "Save all" },
    ["<C-c><C-c>"] = { ":wq<CR>", "Save and close" },
  }

  -- Insert mode bindings
  wk_register({
    ["<C-s>"] = { "<C-o>:silent! wall<cr>", "Save all" },
    ["<C-c><C-c>"] = { "<C-o>:wq<CR>", "Save and close" },

    -- Digraph (replaces C-k, which I use for LSP signature help in insert mode)
    ["<C-l>"] = { "<C-k>", "Enter digraph" },

    ["<C-A>"] = {
      'copilot#Accept("")',
      "Accept copilot suggestion",
      expr = true,
    },
  }, {
    mode = "i",
  })

  -- Text objects
  for _, mode in pairs { "o", "x" } do
    wk_register({
      ["ih"] = {
        function()
          require("gitsigns.actions").select_hunk()
        end,
        "Inner hunk",
      },
    }, {
      mode = mode,
    })
  end

  --
  -- Command mode
  --

  map(
    "c",
    "%%",
    "<C-R>=fnameescape(expand('%'))<cr>",
    { silent = false, desc = "Buffer path" }
  ) -- Full path
  map(
    "c",
    "$$",
    "<C-R>=fnameescape(expand('%:h').'/')<cr>",
    { silent = false, desc = "Buffer dirname" }
  ) -- Dirname
  map(
    "c",
    "^^",
    "<C-R>=fnameescape(expand('%:t'))<cr>",
    { silent = false, desc = "Buffer basename" }
  ) -- Basename

  --
  -- Visual mode
  --
  map("v", "<C-j>", ":m '>+1<CR>gv=gvzz", { silent = false }) -- Move line down
  map("v", "<C-k>", ":m '<-2<CR>gv=gvzz", { silent = false }) -- Move line down

  wk_register {
    ["<leader>"] = {
      --
      -- Leader root
      --
      [":"] = { "<cmd>Telescope commands<cr>", "Commands" },
      N = { "<cmd>Telescope resume<cr>", "Telescope resume" },
      j = { "<cmd>SplitjoinSplit<cr>", "Split line" },
      k = {
        function()
          if vim.bo.ft == "rust" then
            require("rust-tools.join_lines").join_lines()
          else
            vim.cmd [[SplitjoinJoin]]
          end
        end,
        "Join line",
      },
      q = {
        function()
          require("notify").dismiss { silent = true, pending = true }
        end,
        "Close notifications",
      },

      --
      -- Leader visual
      --

      --
      -- Leader +buffer
      --
      ["b"] = {
        name = "Buffers",
        D = { delete_all_buffers, "Delete all buffers" },
        b = { "<cmd>Telescope buffers<cr>", "Search buffers" },
        d = { ":bd<cr>", "Delete buffer" },
        f = { "<cmd>Telescope filetypes<cr>", "Set filetype" },
        l = { ":b #<cr>", "Goto last" },
        n = { "<cmd>DashboardNewFile<cr>", "New" },
        a = { "<cmd>A<cr>", "Alternative" },
        A = { "<cmd>AS<cr>", "Alternative (split)" },
      },

      --
      -- Leader +code
      --
      ["c"] = {
        name = "Code",
        ["="] = { "<cmd>Format<cr>", "Format" },
        r = { vim.lsp.buf.rename, "Rename" },
        g = {
          name = "Go to",
          d = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },
          r = { "<cmd>Trouble lsp_references<cr>", "References" },
          i = { "<cmd>Trouble lsp_implementations<cr>", "Implementations" },
          t = {
            "<cmd>Trouble lsp_type_definitions<cr>",
            "Type definition",
          },
        },
        d = { "<cmd>Trouble workspace_diagnostics<cr>", "Diagnostics" },
        s = { "<cmd>Trouble lsp_document_symbols<cr>", "Symbols" },
        w = {
          name = "Workspace",
          a = {
            vim.lsp.buf.add_workspace_folder,
            "Add folder…",
          },
          r = {
            vim.lsp.buf.remove_workspace_folder,
            "Remove folder…",
          },
          w = {
            function()
              print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            end,
            "List folders",
          },
        },
      },

      --
      -- Leader +file/fold
      --
      ["f"] = {
        name = "File/Fold",
        r = {
          ":Rename <C-R>=fnameescape(expand('%:t'))<cr>",
          "Rename",
          silent = false,
        },
        D = { ":Remove<CR>", "Delete", silent = false },
        m = {
          ":Move <C-R>=fnameescape(expand('%:h'))<cr>",
          "Move",
          silent = false,
        },
        c = {
          ":Copy <C-R>=fnameescape(expand('%'))<cr>",
          "Copy",
          silent = false,
        },
        h = { "<cmd>Telescope oldfiles<cr>", "History" },
        s = { "<cmd>write<cr>", "Save file" },
        a = { "<cmd>silent! wall<cr>", "Save all" },
        i = { "<cmd>fold<cr>", "Insert fold" },
        [">"] = { "<cmd>set foldlevel+=1 | set foldlevel?<cr>", "Foldlevel+" },
        ["<"] = { "<cmd>set foldlevel-=1 | set foldlevel?<cr>", "Foldlevel-" },
        ["0"] = { "<cmd>set foldlevel=0<cr>", "Foldlevel 0" },
        ["1"] = { "<cmd>set foldlevel=1<cr>", "Foldlevel 1" },
        ["2"] = { "<cmd>set foldlevel=2<cr>", "Foldlevel 2" },
        ["3"] = { "<cmd>set foldlevel=3<cr>", "Foldlevel 3" },
        ["4"] = { "<cmd>set foldlevel=4<cr>", "Foldlevel 4" },
        ["5"] = { "<cmd>set foldlevel=5<cr>", "Foldlevel 5" },
        ["6"] = { "<cmd>set foldlevel=6<cr>", "Foldlevel 6" },
        ["7"] = { "<cmd>set foldlevel=7<cr>", "Foldlevel 7" },
        ["8"] = { "<cmd>set foldlevel=8<cr>", "Foldlevel 8" },
        ["9"] = { "<cmd>set foldlevel=9<cr>", "Foldlevel 9" },
      },

      --
      -- Leader +git
      --
      ["g"] = {
        name = "Git",

        g = { "<cmd>Neogit<cr>", "Status" },

        a = { "<cmd>Gitsigns stage_buffer<cr>", "Stage all" },
        s = { "<cmd>Gitsigns stage_hunk<cr>", "Stage hunk" },
        S = { "<cmd>Gitsigns undo_stage_hunk<cr>", "Unstage hunk" },
        p = { "<cmd>Gitsigns preview_hunk<cr>", "Preview hunk" },
        u = { "<cmd>Gitsigns reset_hunk<cr>", "Undo hunk" },

        b = { "<cmd>Gitsigns blame_line<cr>", "Blame line" },
        B = { "<cmd>Gitsigns blame_line true<cr>", "Blame line (full)" },

        f = { "<cmd>DiffviewFileHistory %<cr>", "File history" },
        d = { "<cmd>DiffviewOpen<cr>", "Show working diff" },
        m = { "<cmd>DiffviewOpen master<cr>", "Show master diff" },

        c = {
          function()
            require("neogit.popups.commit").create()
          end,
          "Commit",
        },
      },

      --
      -- Leader +help/vim
      --
      ["h"] = {
        name = "Help/Neovim",
        ["?"] = { "<cmd>Telescope keymaps", "Keymaps" },
        H = { "<cmd>Telescope highlights<cr>", "Vim highlights" },
        n = { "<cmd>Telescope notify<cr>", "Notification history" },
        b = { "<cmd>Telescope marks<cr>", "Vim bookmarks" },
        c = { "<cmd>Telescope colorscheme<cr>", "Vim colorschemes" },
        h = { "<cmd>Telescope help_tags<cr>", "Search help tags" },
        k = { "<cmd>Telescope keymaps<cr>", "Vim keymaps" },
        m = { "<cmd>Telescope man_pages<cr>", "Search man pages" },
        o = { "<cmd>Telescope vim_options<cr>", "Vim options" },
        p = {
          name = "Packages",
          p = { "<cmd>Lazy<cr>", "Lazy" },
          s = { "<cmd>Lazy sync<cr>", "Sync" },
        },
        r = {
          name = "Reload",
          r = { "<cmd>Telescope reloader<cr>", "Other module" },
          t = {
            function()
              require("mange.theme").reload()
            end,
            "Theme",
          },
          m = {
            function()
              reload_mappings()
            end,
            "Mappings",
          },
        },
      },

      --
      -- Leader +notes
      --
      ["n"] = {
        name = "Notes",
        n = { "<cmd>SplitOrFocus notes.local<cr>", "Local notes" },
      },

      --
      -- Leader +project
      --
      ["p"] = {
        name = "Project",
        d = { "<cmd>Telescope diagnostics<cr>", "Diagnostics" },
        f = { "<cmd>Telescope find_files<cr>", "Find files" },
        i = { "<cmd>SplitOrFocus .git/neovim.lua<cr>", "Project vimrc (lua)" },
        I = {
          "<cmd>SplitOrFocus .git/local.vim<cr>",
          "Project vimrc (vimscript)",
        },
        m = { "<cmd>Telescope git_status<cr>", "Modified files" },
        s = { "<cmd>Telescope lsp_workspace_symbols<cr>", "Symbols" },
        t = { "<cmd>SmartSplit +terminal<cr>", "Terminal" },
        T = { telescope_todos, "Todo comments" },
      },

      --
      -- Leader +search
      --
      ["s"] = {
        name = "Search",
        W = { telescope_cWORD, "WORD under cursor" },
        f = { "<cmd>Telescope find_files<cr>", "Files" },
        h = { "<cmd>Telescope search_history<cr>", "Search history" },
        j = { "<cmd>cnewer<cr>", "Newer quickfix" },
        k = { "<cmd>colder<cr>", "Older quickfix" },
        o = {
          "<cmd>Telescope live_grep grep_open_files=true<cr>",
          "Text in open files",
        },
        s = { "<cmd>Telescope live_grep<cr>", "Search for text" },
        t = { "<cmd>Telescope lsp_workspace_symbols<cr>", "Symbols" },
        w = { telescope_cword, "Word under cursor" },
      },

      --
      -- Leader +Session
      --
      ["S"] = {
        name = "Session",
        l = { "<cmd>SessionLoad<cr>", "Load last session" },
        s = { "<cmd>SessionSave<cr>", "Save session" },
      },

      --
      -- Leader +toggle/open
      --
      ["t"] = {
        name = "Toggle/Open",
        -- Not actually a *toggle*, more like a "Toggle off". Just pressing n/N
        -- will enable the highlights again anyway.
        h = { "<cmd>nohl<cr>", "Search highlights" },

        c = {
          require("mange.cursorline").toggle,
          "Cursorline",
        },
        B = {
          "<cmd>Gitsigns toggle_current_line_blame<cr>",
          "Toggle line blame",
        },
        C = { "<cmd>CccHighlighterToggle<cr>", "Color highlights" },

        f = {
          "<cmd>FormatToggle &ft<cr>",
          "Autoformatting (filetype)",
        },
        F = {
          "<cmd>FormatToggle<cr>",
          "Autoformatting (global)",
        },

        l = { "<cmd>set list! | set list?<cr>", "listchars" },
        n = { "<cmd>set number! | set number?<cr>", "number" },
        w = { "<cmd>set wrap! | set wrap?<cr>", "wrap" },
        s = { "<cmd>set spell! | set spell?<cr>", "spell" },
        t = { "<cmd>TroubleToggle<cr>", "Trouble" },
        d = { "<cmd>TroubleToggle workspace_diagnostics<cr>", "Diagnostics" },
        q = { "<cmd>TroubleToggle quickfix<cr>", "Quickfix list" },
        o = { "<cmd>SymbolsOutline<cr>", "Symbol outline" },
        p = { ":CccPick<cr>", "Color picker" },
        z = { ":TZAtaraxis<CR>", "Zen" },
        Z = { ":TZNarrow<CR>", "Zen lines" },
      },

      --
      -- Leader +window
      --
      ["w"] = {
        name = "Window",
        h = { "<C-w>h", "Left" },
        j = { "<C-w>j", "Down" },
        k = { "<C-w>k", "Up" },
        l = { "<C-w>l", "Down" },
        s = { "<C-w>s", "Split horizontal" },
        v = { "<C-w>v", "Split vertical" },
        q = { "<C-w>q", "Close" },
        o = { "<cmd>TZFocus<CR>", "Only this window" },
      },
    },
  }

  --
  -- Leader (visual)
  --
  wk_register({
    ["<leader>"] = {
      s = {
        name = "Sort",
        s = { ":'<,'>sort<cr>", "Normal" },
        n = { ":'<,'>sort n<cr>", "Number" },
        r = { ":'<,'>sort!<cr>", "Reverse" },
      },
      i = {
        name = "Into",
        ["6"] = { ':<C-u>call base64#v("encode")<cr>', "Base64" },
      },
      z = { ":'<,'>TZNarrow<CR>", "Zen lines" },
      -- Cannot use "<" here right now.
      -- https://github.com/folke/which-key.nvim/issues/173
      f = {
        name = "From",
        ["6"] = { ':<C-u>call base64#v("decode")<cr>', "Base64" },
      },
    },
  }, {
    mode = "v",
  })

  -- Leap
  if_require("leap", function(leap)
    leap.add_default_mappings()
  end)
end

--
-- LSP
--
local function attach_lsp(bufnr)
  local modifiable = vim.bo[bufnr].modifiable

  if modifiable then
    wk_register({
      ["<leader><CR>"] = {
        vim.lsp.buf.code_action,
        "Code action",
      },
    }, {
      buffer = bufnr,
    })

    wk_register({
      ["<leader><CR>"] = {
        vim.lsp.buf.range_code_action,
        "Code action",
      },
      ["="] = { vim.lsp.buf.range_formatting, "Format" },
      ["<leader>="] = {
        vim.lsp.buf.range_formatting,
        "Format",
      },
    }, {
      buffer = bufnr,
      mode = "v",
    })
  end

  -- Normal mode mappings
  wk_register({
    ["K"] = { vim.lsp.buf.hover, "Hover documentation" },
    ["gK"] = {
      require("mange.utils").show_signature_help,
      "Signature help",
    },
    ["gd"] = {
      function()
        require("mange.utils").show_diagnostic_float {
          force = true,
          scope = "line",
        }
      end,
      "Show diagnostics on line",
    },
    ["<C-]>"] = { "<cmd>Trouble lsp_definitions<cr>", "Definitions" },

    ["[e"] = {
      vim.diagnostic.goto_prev,
      "Previous diagnostic",
    },
    ["]e"] = {
      vim.diagnostic.goto_next,
      "Next diagnostic",
    },
  }, {
    buffer = bufnr,
  })

  -- Insert mode mappings
  wk_register({
    ["<C-k>"] = {
      function()
        require("mange.utils").show_signature_help { force = true }
      end,
      "Signature help",
    },
  }, {
    buffer = bufnr,
    mode = "i",
  })
end

return {
  setup = setup,
  attach_lsp = attach_lsp,
  reload = reload_mappings,
  wk_register = wk_register,
}
