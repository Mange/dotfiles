#!/bin/sh
set -e

if [ ! -e /usr/local/bin/brew ]; then
  echo "::::::::::: INSTALLING HOMEBREW :::::::::::"
  ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
fi

brew bundle

# zsh-completions
chmod go-w /usr/local/share
