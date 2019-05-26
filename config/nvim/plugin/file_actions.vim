augroup file_actions
  au!
  au BufWritePost
    \ ~/.config/polybar/config,~/Projects/dotfiles/config/polybar/config
    \ silent !polybar-msg cmd restart >/dev/null 2>/dev/null
augroup END
