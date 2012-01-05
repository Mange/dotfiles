" Stolen from Tim Pope :-)
function! s:align()
  let p = '^\s*|\s.*\s|\s*$'
  if exists(':Tabularize') && getline('.') =~# '^\s*|' && (getline(line('.')-1) =~# p || getline(line('.')+1) =~# p)
    let column = strlen(substitute(getline('.')[0:col('.')],'[^|]','','g'))
    let position = strlen(matchstr(getline('.')[0:col('.')],'.*|\s*\zs.*'))
    Tabularize/|/l1
    normal! 0
    call search(repeat('[^|]*|',column).'\s\{-\}'.repeat('.',position),'ce',line('.'))
  endif
endfunction

inoremap <buffer><silent> <Bar>   <Bar><Esc>:call <SID>align()<CR>a
map <buffer> Q :call <SID>align()<CR>

setlocal nofoldenable " start with everything unfolded
setlocal foldnestmax=2
setlocal foldmethod=indent
setlocal foldlevelstart=3
