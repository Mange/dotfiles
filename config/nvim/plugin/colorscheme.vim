let g:gruvbox_contrast_dark='medium'
let g:gruvbox_contrast_light='hard'
let g:gruvbox_improved_warnings=1
let g:gruvbox_italic=1
colorscheme gruvbox

function! s:Shared()
  runtime plugin/highlight_long_lines.vim

  if has("nvim")
    " Transparent background
    hi Normal ctermbg=None guibg=None
  endif

  " Improve warning look
  hi RedUndercurl cterm=undercurl gui=undercurl guisp=#fb4934
  hi YellowUndercurl cterm=undercurl gui=undercurl guisp=#fabd2f
  hi BlueUndercurl cterm=undercurl gui=undercurl guisp=#83a598

  hi link ALEError RedUndercurl
  hi link ALEWarning YellowUndercurl
  hi link ALEInfo BlueUndercurl

  hi link ALEErrorSign GruvboxRedSign
  hi link ALEWarningSign GruvboxYellowSign
  hi link ALEInfoSign GruvboxBlueSign

  hi link ALEVirtualTextWarning GruvboxYellowBold
  hi link ALEVirtualTextError GruvboxRedBold
  hi link ALEVirtualTextInfo GruvboxBlueBold
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

if $KITTY_THEME == "light"
  call s:Light()
else
  call s:Dark()
endif
