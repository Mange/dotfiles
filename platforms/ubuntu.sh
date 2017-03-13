#!/bin/bash
set -e

cd $(dirname $0)
. ./support/functions.bash

. ./shared/rvm.sh
. ./shared/rust.sh

apt-install() {
  echo "${cyan}╸ sudo apt install -y ${*}${reset}"
}

install-apts() {
  local filename="$1"
  local title="$2"
  header "Installing $title"
  sed "s/#.*\$//" $filename | while read line; do
    [[ -z $line ]] && continue

    echo -n ${cyan}╸ sudo apt $line$red

    set +e
    output="$(sudo apt -qq $line 2>&1)"
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

install-fonts() {
  (cd ../fonts && make)
}

install-chrome() {
  apt-install libxss1
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo dpkg -i google-chrome*.deb
  rm google-chrome*.deb
}

install-i3-gaps() {
  # From: https://github.com/Airblader/i3/wiki/Compiling-&-Installing#ubuntu--1610
  apt-install \
    libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev libxcb-icccm4-dev libyajl-dev libstartup-notification0-dev libxcb-randr0-dev libev-dev libxcb-cursor-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev autoconf libxcb-xrm0 libxcb-xrm-dev
  (cd ../vendor && make i3-gaps-install)
}

install-i3blocks-gaps() {
  (cd ../vendor && make i3blocks-gaps-install)
}

install-playerctl() {
  apt-install gtk-doc-tools gobject-introspection libglib2.0-dev
  (cd ../vendor && make playerctl-install)
}

install-lastpass-cli() {
  # https://github.com/lastpass/lastpass-cli
  apt-install openssl libcurl4-openssl-dev libxml2 libssl-dev libxml2-dev pinentry-curses xclip
  # README didn't say, but this is also required:
  apt-install cmake asciidoc
  (cd ../vendor && make lastpass-cli-install)
}

handle-failure() {
  echo ${red}Command failed!${reset}
  echo "Continue? [Yn]"
  read -r answer
  if [[ $answer != "" && $answer != "y" && $answer != "Y" ]]; then
    echo "Aborting"
    exit 1
  fi
}

# Ask for password right away.
sudo echo > /dev/null

install-apts ubuntu/apts.txt "CLI software" || handle-failure

install-rustup || handle-failure
install-crates rust/crates.txt "Rust software" || handle-failure
cargo-update || handle-failure

if hash X 2>/dev/null; then
  install-apts ubuntu/apts-x11.txt "X software" || handle-failure

  header "Installing fonts"
  install-fonts || handle-failure

  if ! hash i3 2>/dev/null; then
    header "Installing i3-gaps"
    install-i3-gaps || handle-failure
  fi

  if ! hash i3blocks 2>/dev/null; then
    header "Installing i3blocks-gaps"
    install-i3blocks-gaps || handle-failure
  fi

  if ! hash google-chrome 2>/dev/null; then
    header "Installing Google Chrome"
    install-chrome || handle-failure
  fi

  if ! hash playerctl 2>/dev/null; then
    header "Installing playerctl"
    install-playerctl || handle-failure
  fi

  if ! hash lpass 2>/dev/null; then
    header "Installing lastpass-cli"
    install-lastpass-cli || handle-failure
  fi
fi

./shared/di.sh || handle-failure

header "Installing updates"
sudo apt -qq update && sudo apt full-upgrade
