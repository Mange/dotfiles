#!/bin/bash
set -e

if [[ -z "$CARGO_HOME" ]]; then
  CARGO_HOME="$HOME/.cargo"
fi

install-or-update-rustup() {
  if [[ ! -f "$CARGO_HOME/env" ]]; then
    header "Installing rustup"
    export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/cargo"
    export RUSTUP_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/rustup"
    curl https://sh.rustup.rs -sSf | sh
  else
    header "Updating Rust"
    run-rust-cmd-quietly rustup update
  fi
}

install-rustup-components() {
  header "Installing Nightly Rust"
  run-rust-cmd-quietly rustup install nightly

  header "Adding Rust editor components"
  run-rust-cmd-quietly rustup component add rust-src
  run-rust-cmd-quietly rustup component add clippy
  run-rust-cmd-quietly rustup component add rls
  run-rust-cmd-quietly rustup component add rust-analysis
  run-rust-cmd-quietly rustup component add rustfmt

  run-rust-cmd-quietly rustup component add rust-src --toolchain=nightly
  run-rust-cmd-quietly rustup component add clippy --toolchain=nightly
  run-rust-cmd-quietly rustup component add rls --toolchain=nightly
  run-rust-cmd-quietly rustup component add rust-analysis --toolchain=nightly
  run-rust-cmd-quietly rustup component add rustfmt --toolchain=nightly
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

install-nightly-crates() {
  install-crates-base "$1" "$2" +nightly
  local filename="$1"

  sed "s/#.*\$//" "${filename}" | while read -r crate; do
    [[ -z $crate ]] && continue

    echo -n "${cyan}╸ cargo install-update-config --toolchain nightly ${crate}${red}"
    set +e
    output="$(run-rust-cmd cargo install-update-config --toolchain nightly "${crate}" 2>&1)"
    if [[ $? == 0 ]]; then
      echo -n "${green} ✔ ${reset}"
    else
      echo "${red} ✘"
      echo "${output} ${reset}"
    fi
    echo "${reset}"
    set -e
  done
}

cargo-update() {
  header "Updating all crates"
  run-rust-cmd-quietly cargo install-update -a
}
