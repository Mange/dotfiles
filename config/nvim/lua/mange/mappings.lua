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
local api = vim.api
local utils = require "mange.utils"

local genghis = require "genghis"
local Snacks = require "snacks"

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
-- This function will only delete all buffers that are loaded, listed, and not
-- modified and leave the rest alone.
local function delete_all_buffers()
  local buffers = vim.tbl_filter(function(buf)
    return vim.api.nvim_buf_is_loaded(buf)
      and vim.bo[buf].buflisted
      and not vim.bo[buf].modified
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
  vim.keymap.set(
    -- Restore <C-i> after <tab> is taken. See :help tui-input
    "n",
    "<C-i>",
    "<C-i>",
    { desc = "Jump forward", remap = false }
  )

  -- Neovide-specific
  if vim.g.neovide then
    vim.keymap.set({ "n", "v" }, "<C-+>", function()
      vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1
    end)
    vim.keymap.set({ "n", "v" }, "<C-->", function()
      vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1
    end)
    vim.keymap.set({ "n", "v" }, "<C-0>", function()
      vim.g.neovide_scale_factor = 1
    end)

    -- Replicate paste keys from Wezterm
    vim.keymap.set({ "i" }, "<C-S-v>", "<C-R>+")
    vim.keymap.set({ "i" }, "<C-S-s>", "<C-R>*")

    vim.keymap.set({ "n" }, "<C-z>", function()
      Snacks.terminal()
    end, { desc = "Toggle terminal" })
  end

  --
  -- Flash
  --
  vim.keymap.set({ "n", "x", "o" }, "<cr>", function()
    require("flash").jump()
  end, { desc = "Flash" })

  vim.keymap.set({ "n", "x", "o" }, "<bs>", function()
    require("flash").treesitter()
  end, { desc = "Flash Treesitter" })

  vim.keymap.set("o", "r", function()
    require("flash").remote()
  end, { desc = "Remote Flash" })

  vim.keymap.set({ "o", "x" }, "R", function()
    require("flash").treesitter_search()
  end, { desc = "Treesitter Search" })

  --
  -- Navigation: [ and ]
  --
  vim.keymap.set("n", "[t", function()
    require("neotest").jump.prev()
  end, { desc = "Previous test" })

  vim.keymap.set("n", "]t", function()
    require("neotest").jump.next()
  end, { desc = "Next test" })

  vim.keymap.set("n", "[T", function()
    require("neotest").jump.prev { status = "failed" }
  end, { desc = "Previous failing test" })

  vim.keymap.set("n", "]T", function()
    require("neotest").jump.next { status = "failed" }
  end, { desc = "Next failing test" })

  vim.keymap.set({ "n", "t" }, "]]", function()
    Snacks.words.jump(vim.v.count1)
  end, { desc = "Next reference" })

  vim.keymap.set({ "n", "t" }, "[[", function()
    Snacks.words.jump(-vim.v.count1)
  end, { desc = "Prev reference" })

  --
  -- Substitute
  --
  vim.keymap.set(
    "n",
    "s",
    require("substitute").operator,
    { noremap = true, desc = "Substitute" }
  )
  vim.keymap.set(
    "n",
    "ss",
    require("substitute").line,
    { noremap = true, desc = "Line" }
  )
  vim.keymap.set(
    "n",
    "S",
    require("substitute").eol,
    { noremap = true, desc = "Substitute EOL" }
  )
  vim.keymap.set(
    "x",
    "s",
    require("substitute").visual,
    { noremap = true, desc = "Substitute" }
  )
  vim.keymap.set(
    "n",
    "sx",
    require("substitute.exchange").operator,
    { noremap = true, desc = "Exchange" }
  )
  vim.keymap.set(
    "n",
    "sxx",
    require("substitute.exchange").line,
    { noremap = true, desc = "Line" }
  )
  vim.keymap.set(
    "x",
    "X",
    require("substitute.exchange").visual,
    { noremap = true, desc = "Exchange" }
  )
  vim.keymap.set(
    "n",
    "sxc",
    require("substitute.exchange").cancel,
    { noremap = true, desc = "Cancel" }
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
    ["-"] = { "<cmd>Oil<CR>", "Open file directory" },

    -- Asterisk * should only set the current search, not jump to the next match.
    ["*"] = {
      ":let @/ = '\\<<C-R>=fnameescape(expand('<cword>'))<CR>\\>'<CR>",
      "Search word under cursor",
    },

    -- Next/previous quickfix
    ["]q"] = {
      function()
        require("trouble").next { mode = "quickfix", jump = true }
      end,
      "Trouble next",
    },
    ["[q"] = {
      function()
        require("trouble").prev { mode = "quickfix", jump = true }
      end,
      "Trouble previous",
    },

    ["cr"] = {
      name = "Coerce",
      ["r"] = { "<cmd>TextCaseOpenTelescope<CR>", "Telescope" },
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
      ["/"] = { "<cmd>nohl<cr>", "nohl" },
      N = { "<cmd>Telescope resume<cr>", "Telescope resume" },
      j = {
        function()
          require("treesj").split()
        end,
        "Split line",
      },
      k = {
        function()
          if vim.bo.ft == "rust" then
            vim.cmd.RustLsp "joinLines"
          else
            require("treesj").join()
          end
        end,
        "Join line",
      },
      q = {
        function()
          require("fidget").notification.clear()
        end,
        "Close notifications",
      },

      --
      -- Leader +buffer
      --
      ["b"] = {
        name = "Buffers",
        y = { ":%y+<cr>", "Yank to clipboard" },
        A = { "<cmd>AS<cr>", "Alternative (split)" },
        D = { delete_all_buffers, "Delete all buffers" },
        a = { "<cmd>A<cr>", "Alternative" },
        b = { "<cmd>Telescope buffers<cr>", "Search buffers" },
        d = { ":bd<cr>", "Delete buffer" },
        f = { "<cmd>Telescope filetypes<cr>", "Set filetype" },
        k = {
          function()
            Snacks.bufdelete()
          end,
          "Kill buffer",
        },
        l = { ":b #<cr>", "Goto last" },
        n = { "<cmd>enew<cr>", "New" },
      },

      --
      -- Leader +code
      --
      ["c"] = {
        name = "Code",
        ["="] = {
          function()
            require("conform").format { async = true, lsp_fallback = true }
          end,
          "Format",
        },
        r = { vim.lsp.buf.rename, "Rename" },
        g = {
          name = "Go to",
          g = {
            "<cmd>Trouble lsp focus=true auto_refresh=false<cr>",
            "All",
          },
          d = {
            "<cmd>Trouble lsp_definitions focus=true auto_refresh=false<cr>",
            "Definitions",
          },
          r = {
            "<cmd>Trouble lsp_references focus=true auto_refresh=false<cr>",
            "References",
          },
          i = {
            "<cmd>Trouble lsp_implementations focus=true auto_refresh=false<cr>",
            "Implementations",
          },
          t = {
            "<cmd>Trouble lsp_type_definitions focus=true auto_refresh=false<cr>",
            "Type definition",
          },
        },
        d = {
          "<cmd>Trouble diagnostics focus=true filter.buf=0<cr>",
          "Diagnostics (buffer)",
        },
        D = { "<cmd>Trouble diagnostics<cr>", "Diagnostics (all)" },
        s = {
          "<cmd>Trouble lsp_document_symbols toggle focus=true pinned=true win.position=right<cr>",
          "Symbols",
        },
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
        f = {
          function()
            require("telescope.builtin").find_files(
              require("telescope.themes").get_dropdown {
                previewer = false,
                cwd = require("telescope.utils").buffer_dir(),
              }
            )
          end,
          "Find sibling",
        },
        r = { genghis.renameFile, "Rename" },
        D = { genghis.trashFile, "Delete" },
        m = { genghis.moveAndRenameFile, "Move" },
        c = { genghis.duplicateFile, "Copy" },
        h = { "<cmd>Telescope oldfiles<cr>", "History" },
        s = { "<cmd>write<cr>", "Save file" },
        a = { "<cmd>silent! wall<cr>", "Save all" },
      },

      --
      -- Leader +git
      --
      ["g"] = {
        name = "Git",

        g = { "<cmd>Neogit<cr>", "Status" },
        o = {
          function()
            Snacks.gitbrowse()
          end,
          "Open Browser",
        },

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
            require("neogit").open { "commit" }
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
        n = { "<cmd>Fidget history<cr>", "Notification history" },
        N = {
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
          "Neovim news",
        },
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
        t = {
          function()
            Snacks.terminal()
          end,
          "Terminal",
        },
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
      -- Leader +test
      --
      ["T"] = {
        name = "Test",

        t = {
          function()
            require("neotest").run.run()
          end,
          "Nearest",
        },

        a = {
          function()
            require("neotest").run.run { suite = true }
          end,
          "All",
        },

        f = {
          function()
            require("neotest").run.run(vim.fn.expand "%")
          end,
          "File",
        },

        d = {
          function()
            require("neotest").run.run(vim.uv.cwd())
          end,
          "CWD",
        },

        l = {
          function()
            require("neotest").run.run_last()
          end,
          "Last",
        },

        s = {
          function()
            require("neotest").run.stop()
          end,
          "Stop",
        },

        o = {
          function()
            require("neotest").output.open { enter = true, auto_close = true }
          end,
          "Show output",
        },

        O = {
          function()
            require("neotest").output_panel.toggle()
          end,
          "Toggle output panel",
        },

        A = {
          function()
            require("neotest").run.attach()
          end,
          "Attach",
        },
      },

      --
      -- Leader +toggle
      -- Most mappings for +toggle is created below using Snacks.toggle.
      --
      ["t"] = {
        name = "Toggle",

        g = { name = "Git" },

        -- Not actually a *toggle*, more like a "Toggle off". Just pressing n/N
        -- will enable the highlights again anyway.
        h = { "<cmd>nohl<cr>", "Disable search highlights" },
      },

      --
      -- Leader +open
      --
      ["o"] = {
        name = "Open",
        a = { ":CodeCompanionChat Toggle<cr>", "AI Chat" },
        A = { ":CodeCompanionActions<cr>", "AI Actions" },
        p = { ":CccPick<cr>", "Color picker" },

        d = { "<cmd>Trouble diagnostics toggle focus=true<cr>", "Diagnostics" },
        q = { "<cmd>Trouble quickfix toggle focus=true<cr>", "Quickfix list" },

        t = {
          function()
            require("neotest").summary.toggle()
          end,
          "Test sumary",
        },
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
  -- Leader (visual & select)
  --
  wk_register({
    ["<leader>"] = {
      a = { ":CodeCompanionChat Toggle<cr>", "AI Chat" },
      A = { "<cmd>CodeCompanionChat Add<cr>", "Add to AI Chat" },
      s = {
        name = "Sort",
        s = { ":'<,'>sort<cr>", "Normal" },
        n = { ":'<,'>sort n<cr>", "Number" },
        r = { ":'<,'>sort!<cr>", "Reverse" },
      },
      i = {
        name = "Into…",
        ["6"] = {
          function()
            local input = utils.get_selection()
            local encoded = vim.base64.encode(input)
            utils.replace_selection(encoded)
            utils.feed_escape()
          end,
          "Base64",
        },
      },
      z = { ":'<,'>TZNarrow<CR>", "Zen lines" },
      -- Cannot use "<" here right now.
      -- https://github.com/folke/which-key.nvim/issues/173
      f = {
        name = "From…",
        ["6"] = {
          function()
            local input = utils.get_selection()
            local decoded = vim.base64.decode(input)
            utils.replace_selection(decoded)
            utils.feed_escape()
          end,
          "Base64",
        },
      },
    },
  }, {
    mode = "v",
  })

  --
  -- Leader (visual)
  --
  wk_register({
    ["<leader>"] = {
      x = {
        name = "Extract…",
        f = { genghis.moveSelectionToNewFile, "…to file" },
      },
    },
  }, {
    mode = "x",
  })
end

--
-- LSP
--
local function attach_lsp(_, bufnr)
  local modifiable = vim.bo[bufnr].modifiable

  local format = function()
    require("conform").format { async = true, lsp_fallback = true }
  end

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
      ["="] = { format, "Format" },
      ["<leader>="] = { format, "Format" },
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
    ["<C-]>"] = { "<cmd>Trouble lsp_definitions focus=true<cr>", "Definitions" },

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
