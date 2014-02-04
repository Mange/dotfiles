#!/bin/sh
set -e

# Keyboard layout
keyboardfile="$HOME/Library/Keyboard Layouts/Manges.keylayout"
if [ ! -e "$keyboardfile" ]; then
  echo "::::::::::: INSTALLING KEYBOARD LAYOUT :::::::::::"
  rm -f "$keyboardfile" # In case we had a broken symlink rather than nothing at all
  ln -s "$(realpath $(dirname $0))/osx/Manges.keylayout" "$keyboardfile"
fi

if [ ! -e /usr/local/bin/brew ]; then
  echo "::::::::::: INSTALLING HOMEBREW :::::::::::"
  ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
fi

brew bundle osx/Brewfile

# zsh-completions
chmod go-w /usr/local/share
