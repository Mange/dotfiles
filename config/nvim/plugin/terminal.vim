augroup terminal_stuff
  autocmd!
  " C-j C-j to enter normal mode. Escape is needed for my shell, which uses
  " vim mode.
  au TermOpen * tnoremap <buffer> <C-j><C-j> <C-\><C-N>

  " Don't show editor-like decorations in a terminal
  au TermOpen * setlocal nonumber nospell nolist

  " Start in insert mode, because I usually only open a terminal to
  " immediately do something in it.
  au TermOpen * startinsert
augroup END
