if_require("autocmd-lua", function(autocmd)
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
        pattern = "markdown,text",
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
end)
