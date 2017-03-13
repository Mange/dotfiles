#!/bin/bash
set -e

install-rustup() {
  if ! hash rustup 2>/dev/null; then
    header "Installing rustup"
    curl https://sh.rustup.rs -sSf | sh
  fi
}

install-crates() {
  local filename="$1"
  local title="$2"
  header "Installing $title"

  local installed_crates=$(cargo install --list | grep -oE '^[^ ]+')
  sed "s/#.*\$//" $filename | while read crate; do
    [[ -z $crate ]] && continue

    echo -n ${cyan}╸ cargo install $crate$red

    if echo "${installed_crates}" | grep --quiet $crate; then
      echo "${yellow} ✔ ${reset}"
      continue
    fi

    set +e
    output="$(cargo install --quiet $crate 2>&1)"
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
  cargo install-update -a
}
