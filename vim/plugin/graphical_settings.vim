if !has("gui_running")
  finish
endif

set guioptions=acei
set list

" Automatically resize splits on window resize
autocmd VimResized * wincmd =

set guifont=Menlo\ for\ Powerline:h12,\ Menlo:h12,\ DejaVu\ Sans\ Mono\ 9

if has("gui_macvim")
  " Fullscreen takes up entire screen
  set fuoptions=maxhorz,maxvert
  set transparency=0
endif

" Shortcuts to use system clipboard
if v:progname =~? "gvim"
  vmap <C-c> "+y
  vmap <C-x> "+x
  nmap <C-v> "+p
  imap <C-v> <C-o>"+p
endif
