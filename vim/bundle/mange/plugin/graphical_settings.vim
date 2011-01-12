if !has("gui_running")
  finish
endif

set guioptions=acei
set list

if has("gui_macvim")
  set guifont=Monaco:h12
  " Fullscreen takes up entire screen
  set fuoptions=maxhorz,maxvert
else
  set guifont=Monaco\ 9,\ DejaVu\ Sans\ Mono\ 9
endif
