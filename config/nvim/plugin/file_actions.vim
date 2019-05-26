augroup file_actions
  au!

  " Polybar
  au BufWritePost
    \ ~/.config/polybar/config,~/Projects/dotfiles/config/polybar/config
    \ silent !polybar-msg cmd restart >/dev/null 2>/dev/null

  " Compton
  au BufWritePost
    \ ~/.config/compton/compton.conf,~/Projects/dotfiles/config/compton/compton.conf
    \ silent !killall -USR1 compton
augroup END
