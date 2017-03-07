#!/bin/bash
set -e

cd $(dirname $0)
. ./support/functions.bash

./shared/rvm.sh

function install-apts() {
  local filename="$1"
  local title="$2"
  header "Installing $title"
  sed "s/#.*\$//" $filename | while read line; do
    [[ -z $line ]] && continue

    echo -n ${cyan}╸ sudo apt-get $line$red

    set +e
    output="$(sudo apt-get -qq $line 2>&1)"
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
  sudo apt-get install libxss1
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo dpkg -i google-chrome*.deb
  rm google-chrome*.deb
}

install-i3-gaps() {
  # From: https://github.com/Airblader/i3/wiki/Compiling-&-Installing#ubuntu--1610
  sudo apt-get install -y \
    libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev libxcb-icccm4-dev libyajl-dev libstartup-notification0-dev libxcb-randr0-dev libev-dev libxcb-cursor-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev autoconf libxcb-xrm0 libxcb-xrm-dev
  (cd ../vendor && make i3-gaps-install)
}

install-playerctl() {
  sudo apt-get install -y gtk-doc-tools gobject-introspection libglib2.0-dev
  (cd ../vendor && make playerctl-install)
}

install-sshrc() {
  sudo add-apt-repository ppa:russell-s-stewart/ppa
  sudo apt-get update
  sudo apt-get install sshrc
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

install-apts ubuntu/apts.txt "CLI software" || handle-failure

# Disabled as Ubuntu 16 (Xenial) has no built binaries, so everything after
# this fails. sources.list.d needs to be cleaned up manually after.
# if ! hash sshrc 2>/dev/null; then
#   header "Installing sshrc"
#   install-sshrc || handle-failure
# fi

if hash X 2>/dev/null; then
  install-apts ubuntu/apts-x11.txt "X software" || handle-failure

  header "Installing fonts"
  install-fonts || handle-failure

  if ! hash i3 2>/dev/null; then
    header "Installing i3-gaps"
    install-i3-gaps || handle-failure
  fi

  if ! hash google-chrome 2>/dev/null; then
    header "Installing Google Chrome"
    install-chrome || handle-failure
  fi

  if ! hash playerctl 2>/dev/null; then
    header "Installing playerctl"
    install-playerctl || handle-failure
  fi
fi

./shared/di.sh || handle-failure

header "Installing updates"
sudo apt-get -qq update && sudo apt-get dist-upgrade
