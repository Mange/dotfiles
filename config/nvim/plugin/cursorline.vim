augroup cursorline
  autocmd!
  autocmd WinEnter,BufEnter * call CursorLineApply()
  autocmd WinLeave,BufLeave * setlocal nocursorline
augroup END
