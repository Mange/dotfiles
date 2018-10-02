setlocal spell

" Automatically move to the top and go to insert mode
if expand('%:t') == 'COMMIT_EDITMSG'
  goto 1
  startinsert
endif
