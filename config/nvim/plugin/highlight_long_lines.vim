" Thanks to bronson/vim-trailing-whitespace for a reference on how to
" implement this! <3

highlight LongLine ctermbg=darkred ctermfg=white guibg=darkred
autocmd ColorScheme * highlight LongLine ctermbg=darkred ctermfg=white guibg=darkred

autocmd InsertEnter * match LongLine /\%100c./

" This is a test line.  This is a test line.  This is a test line.  This is a test line.  This is a test line.  This is a test line.
