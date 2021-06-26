#!/bin/bash
set -e

if [[ -z "$CARGO_HOME" ]]; then
  CARGO_HOME="$HOME/.cargo"
fi

install-rustup-components() {
  header "Updating Rust"
  run-rust-cmd-quietly rustup update

  header "Adding Rust editor components"
  run-rust-cmd-quietly rustup component add rust-src
  run-rust-cmd-quietly rustup component add clippy
  run-rust-cmd-quietly rustup component add rust-analysis
  run-rust-cmd-quietly rustup component add rustfmt
}

run-rust-cmd-quietly() {
  run-command-quietly "$*" < <("$@" 2>&1)
}

run-rust-cmd() {
  if hash "$1" 2>/dev/null; then
    command "$@"
  elif [[ -f "$CARGO_HOME/env" ]]; then
    # This is handled by my dotfiles already, but this script can run before
    # the dotfiles have been installed so deal with that.
    # shellcheck source=/home/mange/.local/share/cargo/env
    source "$CARGO_HOME/env"
    command "$@"
  else
    echo "Cargo/Rustup is not installed!"
    exit 1
  fi
}

install-crates-base() {
  local filename="$1"
  local title="$2"
  local extra_options=($3)

  header "Installing $title"

  local installed_crates
  installed_crates=$(run-rust-cmd cargo "${extra_options[@]}" install --list | grep -oE '^[^ ]+')

  sed "s/#.*\$//" "${filename}" | while read -r crate; do
    [[ -z $crate ]] && continue

    echo -n "${cyan}╸ cargo ${extra_options} install ${crate}${red}"

    if echo "${installed_crates}" | grep --quiet "${crate}"; then
      echo "${yellow} ✔ ${reset}"
      continue
    fi

    set +e
    output="$(run-rust-cmd cargo "${extra_options[@]}" install --quiet "${crate}" 2>&1)"
    if [[ $? == 0 ]]; then
      echo -n "${green} ✔ ${reset}"
    else
      echo "${red} ✘"
      echo "${output} ${reset}"
    fi
    echo "${reset}"
    set -e

  done
  echo
}

install-crates() {
  install-crates-base "$1" "$2"
}

cargo-update() {
  header "Updating all crates"
  run-rust-cmd-quietly cargo install-update -a
}
