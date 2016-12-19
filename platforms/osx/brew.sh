#!/bin/bash

brew update

# "install foo", where already installed version x, while latest is version x+n
# will cause an error and abort the process. We upgrade all packages first to
# avoid these problems.
brew upgrade

brew install coreutils
brew install findutils --default-names

# Replace ancient version in OS X
brew install bash

brew install ag
brew install ctags
brew install fortune
brew install fzf
brew install git
brew install hub
brew install nmap
brew install node
brew install ssh-copy-id
brew install sshrc
brew install tmux
brew install tree
brew install watch
brew install wget
brew install zsh-completions

brew install macvim --with-override-system-vim --with-luajit --with-python3

brew tap homebrew/dupes
brew install grep --default-names
brew install rsync

# Command decorators
brew install colordiff
brew install diff-so-fancy
brew install lesspipe --syntax-highlighting

brew tap caskroom/cask
brew tap caskroom/fonts
brew install brew-cask

brew cask install alfred

# Cask is removed
# brew cask install antirsi
if [[ ! -d /Applications/AntiRSI.app ]]; then
  open "http://antirsi.onnlucky.com/"
fi

brew cask install bettertouchtool
brew cask install dropbox
brew cask install google-chrome google-hangouts google-drive
brew cask install iterm2
brew cask install skype

brew cask install seil
brew cask install karbiner
brew cask install slate
brew cask install flux

brew cask install dash

brew cask install spotify
brew cask install steam
brew cask install ukelele

brew cask install qlcolorcode
brew cask install qlmarkdown
brew cask install qlprettypatch
brew cask install qlstephen
brew cask install quicklook-csv

brew cask install font-dejavu-sans
brew cask install font-dejavu-sans-mono-for-powerline
