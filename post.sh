#!/usr/bin/env bash
# Run after installing dotfiles to perform extra work.

# Clean up old installations of ZSH syntax highlighting, etc.

if [[ -d ~/.config/zsh/vendor ]]; then
  echo "Deleting old zsh/vendor directory"
  rm -rf ~/.config/zsh/vendor
fi
