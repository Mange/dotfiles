fun! MaybeFixWhitespace()
  " Don't strip on filetypes that are also not highlighted by the
  " trailing-whitespace plugin.
  if index(g:extra_whitespace_ignored_filetypes, &ft) < 0
    FixWhitespace
  endif
endfun

autocmd BufWritePre * call MaybeFixWhitespace()
