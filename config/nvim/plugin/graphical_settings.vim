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

if has("gui_macvim")
  set guifont=DejaVu\ Sans\ Mono\ for\ Powerline:h14,\ DejaVu\ Sans\ Mono:h14
  " Fullscreen takes up entire screen
  set fuoptions=maxhorz,maxvert
  set transparency=0

  " Don't clobber system clipboard in visual mode
  " OS X don't have selection/clipboard distinction ("* vs "+ registers)
  set guioptions-=a
else
  set guifont=DejaVu\ Sans\ Mono\ for\ Powerline\ 10,\ DejaVu\ Sans\ Mono\ 10
endif

" Shortcuts to use system clipboard
if v:progname =~? "gvim"
  vmap <C-c> "+y
  vmap <C-x> "+x
  nmap <C-v> "+P
  imap <C-v> <C-r>+
endif