if !has("gui_running")
  finish
endif

set guioptions=acei
set list

" Automatically resize splits on window resize
autocmd VimResized * wincmd =

" Display textwidth
if exists("&colorcolumn")
  set colorcolumn=+1,+2,+3
endif

set guifont=Fira\ Code\ 10

" Shortcuts to use system clipboard
if v:progname =~? "gvim"
  vmap <C-c> "+y
  vmap <C-x> "+x
  nmap <C-v> "+P
  imap <C-v> <C-r>+
endif
