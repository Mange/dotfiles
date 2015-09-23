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
brew install git
brew install hub
brew install lesspipe --syntax-highlighting
brew install colordiff
brew install ctags
brew install fortune
brew install nmap
brew install node
brew install ssh-copy-id
brew install sshrc
brew install tmux
brew install tree
brew install watch
brew install wget
brew install zsh-completions

brew install macvim --override-system-vim --with-luajit --with-python3

brew tap homebrew/dupes
brew install grep --default-names
brew install rsync

brew tap caskroom/cask
brew tap caskroom/fonts
brew install brew-cask

brew cask install alfred
brew cask install antirsi
brew cask install bettertouchtool
brew cask install dropbox
brew cask install google-chrome google-hangouts google-drive
brew cask install iterm2
brew cask install lastpass-universal
brew cask install skype

brew cask install seil
brew cask install karbiner
brew cask install slate
brew cask install flux

brew cask install skitch
brew cask install dash

brew cask install spotify
brew cask install steam
brew cask install ukelele

brew cask install jsonlook
brew cask install qlcolorcode
brew cask install qlmarkdown
brew cask install qlprettypatch
brew cask install qlstephen
brew cask install quicklook-csv

brew cask install font-dejavu-sans
brew cask install font-dejavu-sans-mono-for-powerline
