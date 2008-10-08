" manpageviewPlugin.vim
"   Author: Charles E. Campbell, Jr.
"   Date:   Jun 10, 2008
"   Version: 20
" ---------------------------------------------------------------------
"  Load Once: {{{1
if &cp || exists("g:loaded_manpageviewPlugin")
 finish
endif
let s:keepcpo= &cpo
set cpo&vim

" ---------------------------------------------------------------------
" Public Interface: {{{1
if !hasmapto('<Plug>ManPageView') && &kp =~ '^man\>'
  nmap <unique> K <Plug>ManPageView
endif
nmap <silent> <script> <Plug>ManPageView	:<c-u>call manpageview#ManPageView(1,v:count,expand("<cWORD>"))<CR>

com! -nargs=* -count=0	Man  call manpageview#ManPageView(0,<count>,<f-args>)
com! -nargs=* -count=0	HMan let g:manpageview_winopen="hsplit"|call manpageview#ManPageView(0,<count>,<f-args>)
com! -nargs=* -count=0	OMan let g:manpageview_winopen="only"  |call manpageview#ManPageView(0,<count>,<f-args>)
com! -nargs=* -count=0	RMan let g:manpageview_winopen="reuse" |call manpageview#ManPageView(0,<count>,<f-args>)
com! -nargs=* -count=0	VMan let g:manpageview_winopen="vsplit"|call manpageview#ManPageView(0,<count>,<f-args>)

" ---------------------------------------------------------------------
"  Restore: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo
" vim: ts=4 fdm=marker
