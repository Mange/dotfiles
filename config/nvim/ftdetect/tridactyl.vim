" Assume most textareas on github.com and gitlab.com are markdown inputs.
" Comments, PR descriptions, etc. are all markdown-formatted.
au BufRead,BufNewFile github.com_*.txt set ft=markdown
au BufRead,BufNewFile gitlab.com_*.txt set ft=markdown
