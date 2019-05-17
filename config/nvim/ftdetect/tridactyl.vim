" Assume most textareas on github.com are markdown inputs. Comments, PR
" descriptions, etc. are all markdown-formatted.
au BufRead,BufNewFile tmp_github.com_* set ft=markdown
