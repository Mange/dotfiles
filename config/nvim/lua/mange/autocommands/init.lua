local cmd = vim.cmd

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
end)

-- Resize splits automatically
cmd [[autocmd VimResized * wincmd =]]

-- Prose no line numbers
cmd [[autocmd FileType vimwiki,markdown,text setlocal nonumber]]

-- Restore <BS> mapping for Vimwiki
cmd [[autocmd Filetype vimwiki nmap <buffer> <BS> <Plug>VimwikiGoBackLink]]
