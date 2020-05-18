install-fzf() {
  if [[ ! -d ~/.fzf ]]; then
    header "Installing fzf"
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install
  fi
}

setup-gpg-auto-retrieve() {
  GNUPGHOME="${GNUPGHOME:-~/.gnupg}"

  if [[ ! -d "$GNUPGHOME" ]]; then
    run-command-quietly "Setting up $GNUPGHOME" < <(
      # Generate a GPG directory by running a command
      gpg --list-keys 2>/dev/null >/dev/null

      if [[ ! -d "$GNUPGHOME" ]]; then
        echo "WARNING: Could not generate $GNUPGHOME directory!"
        exit 1
      fi
    )
  fi

  if ! grep -qE "^keyserver-options auto-key-retrieve" "${GNUPGHOME}/gpg.conf" 2>/dev/null; then
    run-command-quietly "Setting up GPG to auto-retreive keys" < <(
      echo "keyserver-options auto-key-retrieve" >> "${GNUPGHOME}/gpg.conf"
    )
  fi
}

install-ruby-via-rvm() {
  if hash ruby 2>/dev/null; then
    return
  fi

  header "Installing Ruby"

  # shellcheck source=/dev/null
  source "${XDG_CONFIG_HOME}/shells/enable-rvm"
  if [[ -z "$RVM_BIN" ]]; then
    echo "RVM is not installed" >&2
    return 1
  fi

  run-command-quietly "Installing latest Ruby via RVM" < <(
    "${RVM_BIN:-rvm}" install ruby
  )

  run-command-quietly "Setting latest ruby as default version" < <(
    "${RVM_BIN:-rvm}" use --default ruby
  )
}

install-global-ruby-gem() {
  local name="$1"

  # shellcheck source=/dev/null
  source "${XDG_CONFIG_HOME}/shells/enable-rvm"
  if [[ -z "$RVM_BIN" ]]; then
    echo "RVM is not installed" >&2
    return 1
  fi

  if [[ -f "$HOME/.rvm/gemsets/global.gems" ]]; then
    install-global-ruby-gem-user "$name"
  elif [[ -f "/usr/share/rvm/gemsets/global.gems" ]]; then
    install-global-ruby-gem-system "$name"
  else
    echo "${yellow}WARN: Cannot find RVM; aborting just to be safe.${reset}"
    return 1
  fi
}

install-global-ruby-gem-user() {
  local name="$1"
  local gemset="$HOME/.rvm/gemsets/global.gems"

  if ! grep -q "$name" "$gemset"; then
    header "Installing $name"
    run-command-quietly "Marking it for installation on all Ruby upgrades" < <(
      echo "$name" >> "$gemset"
    )

    run-command-quietly "Installing $name in all installed rubies" < <(
      "${RVM_BIN:-rvm}" all 'do' bash -c "ruby -v; gem install '$name'" 2>&1
    )
  fi
}

install-global-ruby-gem-system() {
  local name="$1"
  local gemset="/usr/share/rvm/gemsets/global.gems"

  if ! grep -q "$name" "$gemset"; then
    header "Installing $name"
    init-sudo
    run-command-quietly "Marking it for installation on all Ruby upgrades" < <(
      echo "$name" | sudo tee -a "$gemset" > /dev/null
    )

    run-command-quietly "Installing $name in all installed rubies" < <(
      "${RVM_BIN:-rvm}" all 'do' bash -c "ruby -v; gem install '$name'" 2>&1
    )
  fi
}

update-global-ruby-gem() {
  local name="$1"

  # shellcheck source=/dev/null
  source "${XDG_CONFIG_HOME}/shells/enable-rvm"

  run-command-quietly "Updating $name in all Ruby installs" < <(
    "${RVM_BIN?}" all 'do' bash -c "ruby -v; gem update '$name'" 2>&1
  )
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
      read -r answer </dev/tty
      if [[ -z $answer || $answer = "y" || $answer = "Y" ]]; then
        mkdir -vp "${!var}"
      fi
    fi
  done
}
