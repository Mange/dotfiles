" Stolen from Janus
" https://github.com/carlhuda/janus/blob/master/gvimrc
"
autocmd VimEnter * call s:AutoNerdTree(expand("<amatch>"))

function s:AutoNerdTree(directory)
  let explicitDirectory = isdirectory(a:directory)
  let directory = explicitDirectory || empty(a:directory)

  if explicitDirectory
    exe "cd " . a:directory
  endif

  if directory
    NERDTree
    wincmd p
    bd
  endif
endfunction

