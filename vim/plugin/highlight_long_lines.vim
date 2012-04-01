" Thanks to bronson/vim-trailing-whitespace for a reference on how to
" implement this! <3

highlight LongLine ctermbg=darkred ctermfg=white guibg=#2B1C1C
autocmd ColorScheme * highlight LongLine ctermbg=darkred ctermfg=white guibg=#2B1C1C

autocmd BufWinEnter,InsertEnter,InsertLeave * match LongLine /\%>100v.\+/
