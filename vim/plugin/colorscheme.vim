command! Dark call s:Dark()
function! s:Dark()
  colorscheme Tomorrow-Night
  set background=dark
endfunction

command! Light call s:Light()
function! s:Light()
  colorscheme Tomorrow
  set background=light
endfunction

call s:Dark()
