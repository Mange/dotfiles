" :Rg <re>
"   Opens FZF with the output of a ripgrep search for <re>
command! -bang -nargs=* Rg call fzf#vim#grep('rg --column --line-number --no-heading --smart-case --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>), 1, <bang>0)

let g:fzf_history_dir = '~/.local/share/fzf-history'
