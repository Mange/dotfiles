#!/bin/zsh

setopt extendedglob

if [[ $ZSH_VERSION == 4.3.* ]]; then
  if [[ -f ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  fi
fi

for file in ~/.zshrc.d/S*[^~] ; do
     source $file
done
