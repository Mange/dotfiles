" Assume most textareas on github.com and gitlab.com are markdown inputs.
" Comments, PR descriptions, etc. are all markdown-formatted.
au BufRead,BufNewFile tmp_github.com_* set ft=markdown
au BufRead,BufNewFile tmp_gitlab.com_* set ft=markdown
