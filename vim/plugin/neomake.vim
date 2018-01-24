let s:filetypesToCheck = [
      \"ruby",
      \"javascript",
      \"markdown",
      \"text",
      \"json",
      \"sh",
      \"rust",
      \]

autocmd BufWritePost * if index(s:filetypesToCheck, &ft) >= 0 | Neomake
autocmd BufEnter * if !empty(@%) && filereadable(@%) && index(s:filetypesToCheck, &ft) >= 0 | Neomake
