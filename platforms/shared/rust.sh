#!/bin/bash
set -e

install-or-update-rustup() {
  if [[ ! -f ~/.cargo/env ]]; then
    header "Installing rustup"
    curl https://sh.rustup.rs -sSf | sh
  else
    header "Updating Rust"
    rustup update
  fi
}

run-cargo() {
  if hash cargo 2>/dev/null; then
    command cargo "$@"
  elif [[ -f ~/.cargo/env ]]; then
    # This is handled by my dotfiles already, but this script can run before
    # the dotfiles have been installed so deal with that.
    source ~/.cargo/env
    command cargo "$@"
  else
    echo "Cargo is not installed!"
    exit 1
  fi
}

install-crates() {
  local filename="$1"
  local title="$2"
  header "Installing $title"

  local installed_crates=$(run-cargo install --list | grep -oE '^[^ ]+')
  sed "s/#.*\$//" $filename | while read crate; do
    [[ -z $crate ]] && continue

    echo -n ${cyan}╸ cargo install $crate$red

    if echo "${installed_crates}" | grep --quiet $crate; then
      echo "${yellow} ✔ ${reset}"
      continue
    fi

    set +e
    output="$(run-cargo install --quiet $crate 2>&1)"
    if [[ $? == 0 ]]; then
      echo -n $green ✔ $reset
    else
      echo $red ✘
      echo $output $reset
    fi
    echo $reset
    set -e

  done
  echo
}

cargo-update() {
  header "Updating all creates"
  run-cargo install-update -a
}
