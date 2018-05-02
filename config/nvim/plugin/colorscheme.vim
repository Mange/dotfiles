let g:gruvbox_contrast_dark='medium'
let g:gruvbox_contrast_light='medium'
let g:gruvbox_improved_warnings=1
colorscheme gruvbox

function! s:Shared()
  runtime plugin/highlight_long_lines.vim

  if has("nvim")
    " Transparent background
    hi Normal ctermbg=None guibg=None
  endif

  " Improve warning look
  " Gruvbox has styles for Syntastic built in, so reuse them for Neomake
  hi clear NeomakeWarning
  hi clear NeomakeError

  hi link NeomakeError SyntasticError
  hi link NeomakeWarning SyntasticWarning

  hi link NeomakeErrorSign GruvboxRedSign
  hi link NeomakeWarningSign GruvboxYellowSign
endfunction

command! Dark call s:Dark()
function! s:Dark()
  set background=dark
  call s:Shared()

  " Improve GitGutter look
  hi GitGutterAddLine guibg=#2c3529
  hi GitGutterChangeLine guibg=#353429
  hi GitGutterDeleteLine guibg=#352a29
endfunction

command! Light call s:Light()
function! s:Light()
  set background=light
  call s:Shared()
endfunction

if has("termguicolors")     " set true colors
    set t_8f=[38;2;%lu;%lu;%lum
    set t_8b=[48;2;%lu;%lu;%lum
    set termguicolors
endif

call s:Dark()
