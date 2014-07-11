#!/usr/bin/env bash
set -e

cd $(dirname $0)
. ./support/functions.bash

# Keyboard layout
keyboardfile="/Library/Keyboard Layouts/Manges.keylayout"
if [ ! -e "$keyboardfile" ]; then
  header "Installing keyboard layout"
  sudo cp "$(pwd -P)/osx/Manges.keylayout" "$keyboardfile"
fi

if [ ! -e /usr/local/bin/brew ]; then
  header "Installing Homebrew"
  ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
fi

header "Installing software"
brew bundle osx/Brewfile

if ! ps aux | grep "Alfred 2\.app" > /dev/null 2>&1; then
  if [ -d "$HOME/Applications/Alfred 2.app" ]; then
    header "Starting Alfred"
    open "$HOME/Applications/Alfred 2.app"
    echo "Press enter after letting Alfred start up properly..."
    read x
    brew cask alfred link
  fi
fi

./shared/rvm.sh

if [ ! -d ../vendor/tomorrow-theme ]; then
  header "Installing Tomorrow theme"
  git clone https://github.com/chriskempson/tomorrow-theme.git ../vendor/tomorrow-theme

  # iTerm 2
  open "../vendor/tomorrow-theme/iTerm2/Tomorrow Night.itermcolors"
else
  (cd ../vendor/tomorrow-theme && git pull --rebase)
fi

./shared/di.sh

# zsh-completions
chmod go-w /usr/local/share
