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
      ':Telescope file_browser cwd=<C-R>=expand("%:h")<cr><cr>',
      "Browse file directory",
    },

    -- Asterisk * should only set the current search, not jump to the next match.
    ["*"] = {
      ":let @/ = '\\<<C-R>=expand('<cword>')<CR>\\>'<CR>",
      "Search word under cursor",
    },

    -- Next/previous quickfix
    ["]q"] = { ":cn<CR>", "Quickfix next" },
    ["[q"] = { ":cp<CR>", "Quickfix previous" },

    ["<BS>"] = { "<Plug>(Switch)", "Switch" },

    --
    -- Gitsigns
    --
    ["]c"] = {
      "&diff ? ']c' : '<cmd>lua require(\"gitsigns.actions\").next_hunk()<CR>'",
      "Next hunk",
      expr = true,
    },
    ["[c"] = {
      "&diff ? '[c' : '<cmd>lua require(\"gitsigns.actions\").prev_hunk()<CR>'",
      "Previous hunk",
      expr = true,
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

    ["<M-CR>"] = {
      'copilot#Accept("\\<CR>")',
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
        ':<C-U>lua require("gitsigns.actions").select_hunk()<CR>',
        "Inner hunk",
      },
    }, {
      mode = mode,
    })
  end

  --
  -- Command mode
  --

  map("c", "%%", "<C-R>=expand('%')<cr>", { silent = false }) -- Full path
  map("c", "$$", "<C-R>=expand('%:h').'/'<cr>", { silent = false }) -- Dirname
  map("c", "^^", "<C-R>=expand('%:t')<cr>", { silent = false }) -- Basename
  wk_register({
    ["%%"] = "which_key_ignore",
    ["$$"] = "which_key_ignore",
    ["^^"] = "which_key_ignore",
  }, {
    mode = "c",
  })

  --
  -- Visual mode
  --
  map("v", "<C-j>", ":m '>+1<CR>gv=gvzz", { silent = false }) -- Move line down
  map("v", "<C-k>", ":m '<-2<CR>gv=gvzz", { silent = false }) -- Move line down

  -- Setup leader key to space
  g.mapleader = " "
  g.maplocalleader = "\\"

  wk_register {
    ["<leader>"] = {
      --
      -- Leader root
      --
      [":"] = { "<cmd>Telescope commands<cr>", "Commands" },
      N = { "<cmd>Telescope resume<cr>", "Telescope resume" },
      j = { "<cmd>SplitjoinSplit<cr>", "Split line" },
      k = { "<cmd>SplitjoinJoin<cr>", "Join line" },

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
        n = { ":enew<cr>", "New" },
        a = { "<cmd>A<cr>", "Alternative" },
        A = { "<cmd>AS<cr>", "Alternative (split)" },
      },

      --
      -- Leader +code
      --
      ["c"] = {
        name = "Code",
        ["="] = { "<cmd>Format<cr>", "Format" },
        r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
        g = {
          name = "Go to",
          d = { "<cmd>Telescope lsp_definitions<cr>", "Definitions" },
          r = { "<cmd>Telescope lsp_references<cr>", "References" },
          i = { "<cmd>Telescope lsp_implementations<cr>", "Implementations" },
          t = {
            "<cmd>lua vim.lsp.buf.type_definition()<cr>",
            "Type definition",
          },
        },
        d = { "<cmd>Telescope diagnostics<cr>", "Diagnostics" },
        s = { "<cmd>Telescope lsp_document_symbols<cr>", "Symbols" },
        w = {
          name = "Workspace",
          a = {
            "<cmd>lua vim.lsp.buf.add_workspace_folder()<cr>",
            "Add folder…",
          },
          r = {
            "<cmd>lua vim.lsp.buf.remove_workspace_folder()<cr>",
            "Remove folder…",
          },
          w = {
            "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<cr>",
            "List folders",
          },
        },
      },

      --
      -- Leader +file/fold
      --
      ["f"] = {
        name = "File/Fold",
        r = { ":Rename <C-R>=expand('%:t')<cr>", "Rename", silent = false },
        D = { ":Remove<CR>", "Delete", silent = false },
        m = { ":Move <C-R>=expand('%:h')<cr>", "Move", silent = false },
        c = { ":saveas <C-R>=expand('%')<cr>", "Copy", silent = false },
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

        f = { "<cmd>DiffviewFileHistory<cr>", "File history" },
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
        b = { "<cmd>Telescope marks<cr>", "Vim bookmarks" },
        c = { "<cmd>Telescope colorscheme<cr>", "Vim colorschemes" },
        h = { "<cmd>Telescope help_tags<cr>", "Search help tags" },
        k = { "<cmd>Telescope keymaps<cr>", "Vim keymaps" },
        m = { "<cmd>Telescope man_pages<cr>", "Search man pages" },
        o = { "<cmd>Telescope vim_options<cr>", "Vim options" },
        p = {
          name = "Packer",
          c = { "<cmd>PackerCompile<cr>", "Compile" },
          s = { "<cmd>PackerSync<cr>", "Sync" },
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
        w = { "<cmd>VimwikiTabIndex<cr>", "Wiki" },
        ["/"] = {
          "<cmd>Telescope find_files cwd=~/Documents/Wiki<cr>",
          "Find wiki page",
        },
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
      -- Leader +toggle
      --
      ["t"] = {
        name = "Toggle",
        -- Not actually a *toggle*, more like a "Toggle off". Just pressing n/N
        -- will enable the highlights again anyway.
        h = { "<cmd>nohl<cr>", "Search highlights" },

        c = {
          function()
            require("mange.cursorline").toggle()
          end,
          "Cursorline",
        },
        B = {
          "<cmd>Gitsigns toggle_current_line_blame<cr>",
          "Toggle line blame",
        },
        C = { "<cmd>ColorizerToggle<cr>", "Colorizer" },

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
        q = { "<cmd>ClistToggle<cr>", "Quickfix list" },
        v = { "<cmd>Vista!!<cr>", "Vista" },
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
end

--
-- LSP
--
local function attach_lsp(bufnr)
  local modifiable = vim.bo[bufnr].modifiable

  if modifiable then
    wk_register({
      ["<leader><CR>"] = {
        ":lua vim.lsp.buf.code_action()<cr>",
        "Code action",
      },
    }, {
      buffer = bufnr,
    })

    wk_register({
      ["<leader><CR>"] = {
        ":lua vim.lsp.buf.range_code_action()<cr>",
        "Code action",
      },
      ["="] = { "<cmd>lua vim.lsp.buf.range_formatting()<cr>", "Format" },
      ["<leader>="] = {
        "<cmd>lua vim.lsp.buf.range_formatting()<cr>",
        "Format",
      },
    }, {
      buffer = bufnr,
      mode = "v",
    })
  end

  -- Normal mode mappings
  wk_register({
    ["K"] = { "<Cmd>lua vim.lsp.buf.hover()<CR>", "Hover documentation" },
    ["gK"] = {
      "<cmd>lua require('mange.utils').show_signature_help()<CR>",
      "Signature help",
    },
    ["gd"] = {
      "<cmd>lua require('mange.utils').show_diagnostic_float({force = true})<CR>",
      "Show diagnostics on line",
    },
    ["<C-]>"] = { "<cmd>Telescope lsp_definitions<cr>", "Definitions" },

    ["[e"] = {
      "<cmd>lua vim.diagnostic.goto_prev()<CR>",
      "Previous diagnostic",
    },
    ["]e"] = {
      "<cmd>lua vim.diagnostic.goto_next()<CR>",
      "Next diagnostic",
    },
  }, {
    buffer = bufnr,
  })

  -- Insert mode mappings
  wk_register({
    ["<C-k>"] = {
      "<cmd>lua require('mange.utils').show_signature_help({force = true})<CR>",
      "Signature help",
    },
  }, {
    buffer = bufnr,
    mode = "i",
  })
end

--
-- Vimwiki
--
local function attach_vimwiki(bufnr)
  wk_register({
    ["<CR>"] = { "<Plug>VimwikiFollowLink", "Follow link" },
    ["<S-CR>"] = { "<Plug>VimwikiSplitLink", "Split link" },
    ["<BS>"] = { "<Plug>VimwikiGoBackLink", "Go back" },
    ["<C-Space>"] = { "<Plug>VimwikiToggleListItem", "Toggle list item" },
    ["+"] = { "<Plug>VimwikiNormalizeLink", "Normalize link" },
    ["<LocalLeader>"] = {
      name = "+localleader",
      n = { "<Plug>VimwikiNextTask", "Next task" },
      g = { "<Plug>VimwikiGoto", "Goto (new)" },
      d = { "<Plug>VimwikiDeleteFile", "Delete current" },
      r = { "<Plug>VimwikiRenameFile", "Rename current" },
      l = {
        name = "+lists",
        d = { "<Plug>VimwikiRemoveSingleCB", "Remove checkbox" },
        D = { "<Plug>VimwikiRemoveCBInList", "Remove nested checkboxes" },
        n = { "<Plug>VimwikiIncrementListItem", "Increase done state" },
        l = { "<Plug>VimwikiIncreaseLvlSingleItem", "Increase level" },
        L = { "<Plug>VimwikiIncreaseLvlWholeItem", "Increase level whole" },
        H = { "<Plug>VimwikiDecreaseLvlWholeItem", "Decrease level whole" },
        h = { "<Plug>VimwikiDecreaseLvlSingleItem", "Decrease level" },
        r = { "<Plug>VimwikiRenumberList", "Renumber list" },
        R = { "<Plug>VimwikiRenumberAllLists", "Renumber all" },
        x = { "<Plug>VimwikiToggleRejectedListItem", "Reject item" },
      },
    },
  }, { buffer = bufnr, mode = "n" })

  wk_register({
    ["+"] = { "<Plug>VimwikiNormalizeLinkVisual", "Normalize link" },
  }, { buffer = bufnr, mode = "v" })

  map(
    "i",
    ">>",
    "<C-o><Plug>VimwikiIncreaseLvlSingleItem",
    { buffer = bufnr, noremap = false }
  )
  map(
    "i",
    "<<",
    "<C-o><Plug>VimwikiDecreaseLvlSingleItem",
    { buffer = bufnr, noremap = false }
  )
end

return {
  setup = setup,
  attach_lsp = attach_lsp,
  attach_vimwiki = attach_vimwiki,
  reload = reload_mappings,
  wk_register = wk_register,
}
