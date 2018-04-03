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
