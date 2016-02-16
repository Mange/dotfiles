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

install-chrome() {
  sudo apt-get install libxss1
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  sudo dpkg -i google-chrome*.deb
  rm google-chrome*.deb
}

install-sshrc() {
  sudo add-apt-repository ppa:russell-s-stewart/ppa
  sudo apt-get update
  sudo apt-get install sshrc
}

install-apts ubuntu/apts.txt "CLI software"

if ! hash sshrc 2>/dev/null; then
  header "Installing sshrc"
  install-sshrc
fi

if hash X 2>/dev/null; then
  install-apts ubuntu/apts-x11.txt "X software"

  if ! hash google-chrome 2>/dev/null; then
    header "Installing Google Chrome"
    install-chrome
  fi
fi

./shared/di.sh

header "Installing updates"
sudo apt-get -qq update && sudo apt-get dist-upgrade