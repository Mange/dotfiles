setlocal spell

" Line numbers make no sense in commit messages
setlocal nonumber
setlocal norelativenumber

" Automatically move to the top and go to insert mode
if expand('%:t') == 'COMMIT_EDITMSG'
  goto 1
  startinsert
endif
