install-fzf() {
  if [[ ! -d ~/.fzf ]]; then
    header "Installing fzf"
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install
  fi
}

setup-gpg-auto-retrieve() {
  if [[ ! -d ~/.gnupg ]]; then
    # Generate a GPG directory by running a command
    gpg --list-keys 2>/dev/null >/dev/null

    if [[ ! -d ~/.gnupg ]]; then
      echo "WARNING: Could not generate ~/.gnupg directory!"
      return 1
    fi
  fi

  if ! grep -qE "^keyserver-options auto-key-retrieve" ~/.gnupg/gpg.conf 2>/dev/null; then
    header "Setting up GPG to auto-retreive keys"

    echo "keyserver-options auto-key-retrieve" >> ~/.gnupg/gpg.conf
  fi
}

install-ruby-via-rvm() {
  if hash ruby 2>/dev/null; then
    return
  fi

  header "Installing Ruby"

  if [[ -s /usr/share/rvm/scripts/rvm ]]; then
    source /usr/share/rvm/scripts/rvm
  else
    echo "ERROR: RVM isn't installed?" >/dev/stderr
    return 1
  fi

  subheader "Installing latest Ruby via RVM"
  rvm install ruby

  subheader "Setting latest ruby as default version"
  rvm use --default ruby
}

install-ripper-tags() {
  # shellcheck source=/dev/null
  source "${XDG_CONFIG_HOME}/shells/enable-rvm"

  if [[ -f "$HOME/.rvm/gemsets/global.gems" ]]; then
    install-ripper-tags-local
  elif [[ -f "/usr/share/rvm/gemsets/global.gems" ]]; then
    install-ripper-tags-global
  else
    echo "${yellow}WARN: Cannot find ~/.rvm; aborting just to be safe.${reset}"
    return 1
  fi
}

install-ripper-tags-local() {
  local gemset="$HOME/.rvm/gemsets/global.gems"

  if ! grep -q ripper-tags "$gemset"; then
    header "Installing ripper-tags"
    subheader "Marking it for installation on all Ruby upgrades"
    echo ripper-tags >> "$gemset"

    subheader "Installing ripper-tags in all installed rubies"
    rvm all 'do' bash -c 'ruby -v; gem install ripper-tags'

    echo "${green}Done!${reset}"
  fi
}

install-ripper-tags-global() {
  local gemset="/usr/share/rvm/gemsets/global.gems"

  if ! grep -q ripper-tags "$gemset"; then
    header "Installing ripper-tags"
    subheader "Marking it for installation on all Ruby upgrades"
    echo ripper-tags | sudo tee -a "$gemset" > /dev/null

    subheader "Installing ripper-tags in all installed rubies"
    rvm all 'do' bash -c 'ruby -v; gem install ripper-tags'

    echo "${green}Done!${reset}"
  fi
}

update-ripper-tags() {
  if [[ -s /usr/share/rvm/scripts/rvm ]]; then
    source /usr/share/rvm/scripts/rvm
  else
    echo "ERROR: RVM isn't installed?" >/dev/stderr
    return 1
  fi

  if hash ripper-tags 2>/dev/null; then
    rvm all 'do' bash -c 'ruby -v; gem update ripper-tags'
  fi
}

create-user-dirs() {
  # shellcheck source=/dev/null
  source "./shared/user-dirs.dirs"

  for var in \
    XDG_DESKTOP_DIR XDG_DOCUMENTS_DIR XDG_DOWNLOAD_DIR \
    XDG_MUSIC_DIR XDG_PICTURES_DIR XDG_PUBLICSHARE_DIR \
    XDG_TEMPLATES_DIR XDG_VIDEOS_DIR;
  do
    if [[ ! -d "${!var}" ]]; then
      echo "${!var} does not exist. Create it?"
      echo "Create ${!var}? [Yn] "
      read -r answer
      if [[ -z $answer || $answer = "y" || $answer = "Y" ]]; then
        mkdir -vp "${!var}"
      fi
    fi
  done
}
