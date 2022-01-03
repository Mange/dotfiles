#!/bin/bash
set -e

script_candidates=(
  "${XDG_CONFIG_HOME}/shells/enable-rvm"
  "${HOME}/Projects/dotfiles/config/shells/enable-rvm"
  ../config/shells/enable-rvm
  /usr/share/rvm/scripts/rvm
  /usr/local/rvm/scripts/rvm
  "${HOME}/.rvm/scripts/rvm"
)

for candidate in "${script_candidates[@]}"; do
  if [ -f "$candidate" ]; then
    # shellcheck source=/dev/null
    source "$candidate"
    break
  fi
done

if [[ -z "${RVM_BIN:-}" ]]; then
  # Install RVM to $HOME/.rvm
  \curl -sSL https://get.rvm.io | bash -s -- stable --ignore-dotfiles
  # shellcheck source=/home/mange/.rvm/scripts/rvm
  source "${HOME}/.rvm/scripts/rvm"
fi

if ! hash ruby >/dev/null; then
  "${RVM_BIN:-rvm}" install ruby
  "${RVM_BIN:-rvm}" use --default ruby
fi

# Install standard and solargraph in global gemset
"${RVM_BIN:-rvm}" @global 'do' gem install \
  standard \
  solargraph

"${RVM_BIN:-rvm}" all 'do' gem install \
  standard \
  solargraph
