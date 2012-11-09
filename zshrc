#!/bin/zsh

setopt extendedglob

if [[ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

for file in ~/.zshrc.d/S*[^~] ; do
     source $file
done
