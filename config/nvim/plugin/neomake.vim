let s:filetypesToCheck = [
      \"ruby",
      \"javascript",
      \"markdown",
      \"text",
      \"json",
      \"sh",
      \"rust",
      \]

let s:filenamesToSkip = [
      \"PKGBUILD",
      \]

autocmd BufWritePost * if index(s:filetypesToCheck, &ft) >= 0 && index(s:filenamesToSkip, expand("%:t")) == -1 | Neomake
autocmd BufEnter * if !empty(@%) && filereadable(@%) && index(s:filetypesToCheck, &ft) >= 0 && index(s:filenamesToSkip, expand("%:t")) == -1 | Neomake
