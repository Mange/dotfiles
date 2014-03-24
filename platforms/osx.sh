#!/bin/sh
set -e

cd $(dirname $0)

# Keyboard layout
keyboardfile="/Library/Keyboard Layouts/Manges.keylayout"
if [ ! -e "$keyboardfile" ]; then
  echo "::::::::::: INSTALLING KEYBOARD LAYOUT :::::::::::"
  rm -f "$keyboardfile" # In case we had a broken symlink rather than nothing at all
  ln -s "$(pwd -P)/osx/Manges.keylayout" "$keyboardfile"
fi

if [ ! -e /usr/local/bin/brew ]; then
  echo "::::::::::: INSTALLING HOMEBREW :::::::::::"
  ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
fi

echo "::::::::::: INSTALLING SOFTWARE :::::::::::"
brew bundle osx/Brewfile

if ! ps aux | grep "Alfred 2\.app" > /dev/null 2>&1; then
  if [ -d "$HOME/Applications/Alfred 2.app" ]; then
    echo "::::::::::: STARTING ALFRED :::::::::::"
    open "$HOME/Applications/Alfred 2.app"
    sleep 5
    brew cask alfred link
  fi
fi

if [ ! -d $HOME/.rvm ]; then
  echo "::::::::::: INSTALLING RVM :::::::::::"
  \curl -sSL https://get.rvm.io | bash -s stable
fi

# zsh-completions
chmod go-w /usr/local/share
