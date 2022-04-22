if_require("autocmd-lua", function(autocmd)
  -- Enable folds in my Neovim config files.
  autocmd.augroup {
    group = "mange_vim_folds",
    autocmds = {
      {
        event = "BufRead",
        pattern = "*/nvim/*.lua,*/bin/*.vim",
        cmd = function()
          vim.wo.foldenable = true
          vim.wo.foldmethod = "marker"
          vim.wo.foldlevel = 0
        end,
      },
    },
  }

  autocmd.augroup {
    group = "mange_packer_plugins",
    autocmds = {
      -- Automatically compile packer config on edit.
      {
        event = "BufWritePost",
        pattern = "*/nvim/lua/plugins.lua",
        cmd = function()
          vim.cmd "luafile <afile>"
          vim.cmd "PackerCompile"
        end,
      },
      -- Quick command to PackerSync
      {
        event = "BufRead",
        pattern = "*/nvim/lua/plugins.lua",
        cmd = function()
          vim.keymap.set("n", "Q", function()
            vim.cmd "luafile %"
            vim.cmd "PackerSync"
          end, { buffer = true })
        end,
      },
    },
  }

  autocmd.augroup {
    group = "mange_prose",
    autocmds = {
      -- No visible line numbers
      {
        event = "FileType",
        pattern = "vimwiki,markdown,text",
        cmd = "setlocal nonumber",
      },
    },
  }

  autocmd.augroup {
    group = "mange_ui",
    autocmds = {
      -- Resize splits automatically
      {
        event = "VimResized",
        pattern = "*",
        cmd = "wincmd =",
      },
    },
  }

  autocmd.augroup {
    group = "mange_vimwiki",
    autocmds = {
      -- Attach my mappings to vimwiki buffers
      {
        event = "Filetype",
        pattern = "vimwiki",
        cmd = function()
          require("mange.mappings").attach_vimwiki(0)
        end,
      },
    },
  }
end)
