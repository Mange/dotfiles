if !has("gui_running")
  finish
endif

set guioptions=acei
set list

" Automatically resize splits on window resize
autocmd VimResized * wincmd =

if has("gui_macvim")
  set guifont=Menlo:h12
  " Fullscreen takes up entire screen
  set fuoptions=maxhorz,maxvert

  set transparency=0
else
  set guifont=DejaVu\ Sans\ Mono\ 9
endif

" Shortcuts to use system clipboard
if v:progname =~? "gvim"
  vmap <C-c> "+y
  vmap <C-x> "+x
  nmap <C-v> "+p
  imap <C-v> <C-o>"+p
endif
