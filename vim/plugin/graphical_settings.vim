if !has("gui_running")
  finish
endif

set guioptions=acei
set list

if has("gui_macvim")
  set guifont=Menlo:h12
  " Fullscreen takes up entire screen
  set fuoptions=maxhorz,maxvert

  set transparency=0
else
  set guifont=DejaVu\ Sans\ Mono\ 9
endif
