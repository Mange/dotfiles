#!/usr/bin/env bash
# Run after installing dotfiles to perform extra work.

# Clean up old installations of ZSH syntax highlighting, etc.
if [[ -d ~/.config/zsh/vendor ]]; then
  echo "Deleting old zsh/vendor directory"
  rm -rf ~/.config/zsh/vendor
fi

# Make sure termite has a config
if [[ ! -f "$XDG_CONFIG_HOME/termite/config" ]]; then
  "${HOME}/.local/bin/termite-config"
fi

# Create directory for vdirsyncer settings
mkdir -p ~/.local/share/vdirsyncer

# Install Vim plugs
if [[ ! -f "${XDG_DATA_HOME}/nvim/site/autoload/plug.vim" ]]; then
  echo "Downloading Vim plug"
  curl \
    --create-dirs --silent --fail --location \
    --output "${XDG_DATA_HOME}/nvim/site/autoload/plug.vim" \
    "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
fi

# Update / install Vim plugins
nvim -u "${XDG_CONFIG_HOME}/nvim/plugs.vim" +PlugInstall +qa

if [[ "$SHELL" != *zsh ]]; then
  echo "Warning: You seem to be using a shell different from zsh (${SHELL})" > /dev/stderr
  echo "Fix this by running:" > /dev/stderr
  echo "  chsh -s \$(which zsh)" > /dev/stderr
fi
