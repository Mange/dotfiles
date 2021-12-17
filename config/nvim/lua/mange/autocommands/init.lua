local cmd = vim.cmd

-- Enable folds in my Neovim config files.
cmd [[
  autocmd BufRead */nvim/*.lua,*/nvim/*.vim set foldenable foldmethod=marker foldlevel=0
]]

-- Quick command to PackerSync when editing packages
cmd [[
  autocmd BufRead */nvim/lua/plugins.lua nmap <buffer> Q :PackerSync<CR>
]]

-- Resize splits automatically
cmd [[autocmd VimResized * wincmd =]]

-- Prose no line numbers
cmd [[autocmd FileType vimwiki,markdown,text setlocal nonumber]]

-- Restore <BS> mapping for Vimwiki
cmd [[autocmd Filetype vimwiki nmap <buffer> <BS> <Plug>VimwikiGoBackLink]]
