#!/bin/sh
set -e

cd $(dirname $0)

# Keyboard layout
keyboardfile="/Library/Keyboard Layouts/Manges.keylayout"
if [ ! -e "$keyboardfile" ]; then
  echo "::::::::::: INSTALLING KEYBOARD LAYOUT :::::::::::"
  sudo cp "$(pwd -P)/osx/Manges.keylayout" "$keyboardfile"
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
    echo "Press enter after letting Alfred start up properly..."
    read x
    brew cask alfred link
  fi
fi

if [ ! -d "$HOME/.rvm" ]; then
  echo "::::::::::: INSTALLING RVM :::::::::::"
  \curl -sSL https://get.rvm.io | bash -s stable
fi

if [ ! -d ../vendor/tomorrow-theme ]; then
  echo "::::::::::: INSTALLING TOMORROW THEME :::::::::::"
  git clone https://github.com/chriskempson/tomorrow-theme.git ../vendor/tomorrow-theme

  # Install Chrome theme
  mkdir -p "$HOME/Library/Application\ Support/Google/Chrome/Default/User/"
  cp "../vendor/tomorrow-theme/Google Chrome Developer Tools/Custom.css" "$HOME/Library/Application\ Support/Google/Chrome/Default/User/Custom.css"

  # iTerm 2
  open "../vendor/tomorrow-theme/iTerm2/Tomorrow Night.itermcolors"
fi

if [ ! -d "$HOME/Music/Radio/DI" ]; then
  echo "::::::::::: DOWNLOADING RADIO PLAYLISTS :::::::::::"
  mkdir -p "$HOME/Music/Radio/DI"
  ../bin/di-download
fi

# zsh-completions
chmod go-w /usr/local/share
