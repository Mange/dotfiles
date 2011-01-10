if !has("gui_running")
  finish
endif

set guioptions=acei
set background=dark
colorscheme vividchalk
set listchars=tab:→\ ,eol:¬
set list

if has("gui_macvim")
  " Fullscreen takes up entire screen
  set fuoptions=maxhorz,maxvert

  set guifont=Monaco:h12
else
  set guifont=Monaco\ 9,\ DejaVu\ Sans\ Mono\ 9
endif
