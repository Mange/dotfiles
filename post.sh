#!/usr/bin/env bash
# Run after installing dotfiles to perform extra work.

# Create directory for ZSH history, etc., if it does not exist already.
mkdir -p "${XDG_DATA_HOME}/zsh"

# Setup theme if it appears to not be set up already
if [[ ! -s "${XDG_CONFIG_HOME}/kitty/theme.conf" ]]; then
  ~/.local/bin/_theme_set dark
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

# Install Vim plugins
if [[ ! -d "${XDG_DATA_HOME}/nvim/plugged" ]]; then
  nvim -u "${XDG_CONFIG_HOME}/nvim/plugs.vim" +PlugInstall +qa
fi

# Install zsh plugins
if [[ -d "${XDG_CONFIG_HOME}/zsh/fzf-tab" ]]; then
  (cd "${XDG_CONFIG_HOME}/zsh/fzf-tab" && git pull --rebase --quiet)
else
  git clone https://github.com/Aloxaf/fzf-tab "${XDG_CONFIG_HOME}/zsh/fzf-tab"
fi

if [[ "$SHELL" != *zsh ]]; then
  echo "Warning: You seem to be using a shell different from zsh (${SHELL})" > /dev/stderr
  echo "Fix this by running:" > /dev/stderr
  echo "  chsh -s \$(which zsh)" > /dev/stderr
fi
