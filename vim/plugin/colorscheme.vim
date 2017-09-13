let g:gruvbox_contrast_dark='medium'
let g:gruvbox_contrast_light='medium'
colorscheme gruvbox

function! s:Shared()
  runtime plugin/highlight_long_lines.vim

  " Transparent background
  hi Normal ctermbg=None guibg=None

  " Highlight searches using only underlines
  hi clear Search
  hi Search term=underline cterm=underline gui=underline

  " Improve spelling look in terminal
  hi clear SpellBad
  hi SpellBad term=undercurl,bold cterm=undercurl,bold ctermfg=red gui=undercurl guisp=Red
  hi clear SpellCap
  hi SpellCap term=undercurl,bold cterm=undercurl,bold ctermfg=blue gui=undercurl guisp=blue

  " Improve warning look
  hi clear NeomakeWarning
  hi link NeomakeWarning SpellCap
  hi NeomakeWarningSign ctermfg=yellow guifg=yellow
  hi NeomakeErrorSign ctermfg=red guifg=red
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
    set t_8f=\[[38;2;%lu;%lu;%lum
    set t_8b=\[[48;2;%lu;%lu;%lum
    set termguicolors
endif

call s:Dark()
