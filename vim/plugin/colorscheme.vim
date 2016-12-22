function! s:Shared()
  runtime plugin/highlight_long_lines.vim

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
  hi NeomakeWarning ctermbg=magenta ctermfg=black gui=undercurl guisp=magenta
  hi NeomakeWarningSign ctermfg=yellow guifg=yellow
  hi NeomakeErrorSign ctermfg=red guifg=red
endfunction

command! Dark call s:Dark()
function! s:Dark()
  colorscheme Tomorrow-Night
  set background=dark
  call s:Shared()

  " Improve GitGutter look
  hi GitGutterAddLine guibg=#2c3529
  hi GitGutterChangeLine guibg=#353429
  hi GitGutterDeleteLine guibg=#352a29
endfunction

command! Light call s:Light()
function! s:Light()
  colorscheme Tomorrow
  set background=light
  call s:Shared()
endfunction

call s:Dark()
