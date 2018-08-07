#!/bin/bash
set -e

install-or-update-rustup() {
  if [[ ! -f ~/.cargo/env ]]; then
    header "Installing rustup"
    curl https://sh.rustup.rs -sSf | sh
  else
    header "Updating Rust"
    run-rust-cmd rustup update
  fi
}

install-rustup-components() {
  header "Installing Nightly Rust"
  run-rust-cmd rustup install nightly

  header "Adding Rust editor components"
  run-rust-cmd rustup component add rust-src
  run-rust-cmd rustup component add rls-preview
  run-rust-cmd rustup component add rust-analysis
  run-rust-cmd rustup component add rustfmt-preview
  run-rust-cmd rustup component add clippy-preview --toolchain=nightly
}

run-rust-cmd() {
  if hash "$1" 2>/dev/null; then
    command "$@"
  elif [[ -f ~/.cargo/env ]]; then
    # This is handled by my dotfiles already, but this script can run before
    # the dotfiles have been installed so deal with that.
    source ~/.cargo/env
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
  run-rust-cmd cargo install-update -a
}
