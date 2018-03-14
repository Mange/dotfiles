#!/bin/bash
set -e

cd $(dirname $0)
. ./support/functions.bash

. ./shared/generic.sh
. ./shared/rust.sh

apt-install() {
  echo "${cyan}╸ sudo apt-get install -y ${*}${reset}"
  sudo apt-get install -y "$@"
}

install-apts() {
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

install-firefox-developer-edition() {
  if ! hash ubuntu-make.snap 2>/dev/null; then
    subheader "Installing Ubuntu Make"
    sudo snap install --classic ubuntu-make
  fi

  subheader "Installing Firefox Developer Edition"
  /snap/bin/ubuntu-make.umake web firefox-dev
}

install-i3-gaps() {
  # From: https://github.com/Airblader/i3/wiki/Compiling-&-Installing#ubuntu--1610
  apt-install \
    libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev libxcb-icccm4-dev libyajl-dev libstartup-notification0-dev libxcb-randr0-dev libev-dev libxcb-cursor-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev autoconf libxcb-xrm0 libxcb-xrm-dev
  (cd ../vendor && make i3-gaps-install)
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

install-rofi-lpass() {
  (cd ../vendor && make rofi-lpass-install)
}

# Ask for password right away.
sudo echo > /dev/null

# For example: "zesty"
dist_name=$(lsb_release --short --codename)

getdeb_file=/etc/apt/sources.list.d/getdeb.list
if [[ ! -e $getdeb_file ]]; then
  header "Installing GetDeb repository"
  echo "deb http://archive.getdeb.net/ubuntu ${dist_name}-getdeb apps" | sudo tee "$getdeb_file" > /dev/null
  wget -q -O- http://archive.getdeb.net/getdeb-archive.key | sudo apt-key add -
fi

if hash X 2>/dev/null; then
  copyq_files=$(shopt -s nullglob; echo /etc/apt/sources.list.d/*copyq*.list)
  if [[ -z $copyq_files ]]; then
    header "Installing CopyQ repository"
    sudo add-apt-repository ppa:hluk/copyq
  fi
fi

header "Refreshing apt cache"
sudo apt -qq update || handle-failure

install-apts ubuntu/apts.txt "CLI software" || handle-failure

install-fzf || handle-failure
install-or-update-rustup || handle-failure
install-rustup-components || handle-failure
install-crates rust/crates.txt "Rust software" || handle-failure
install-nightly-crates rust/nightly-crates.txt "Nightly Rust software" || handle-failure
cargo-update || handle-failure

if hash X 2>/dev/null; then
  install-apts ubuntu/apts-x11.txt "X software" || handle-failure

  header "Installing fonts"
  install-fonts || handle-failure

  if ! hash i3 2>/dev/null; then
    header "Installing i3-gaps"
    install-i3-gaps || handle-failure
  fi

  if ! hash firefox-developer 2>/dev/null; then
    header "Installing Firefox Developer Edition"
    install-firefox-developer-edition || handle-failure
  fi

  if ! hash playerctl 2>/dev/null; then
    header "Installing playerctl"
    install-playerctl || handle-failure
  fi

  if ! hash lpass 2>/dev/null; then
    header "Installing lastpass-cli"
    install-lastpass-cli || handle-failure
  fi

  if ! hash rofi-lpass 2>/dev/null; then
    header "Installing rofi-lpass"
    install-rofi-lpass || handle-failure
  fi

  if hash gsettings 2>/dev/null; then
    gsettings set org.gnome.desktop.background show-desktop-icons false
  fi
fi

./shared/di.sh || handle-failure
./shared/projects.sh || handle-failure

header "Installing updates"
sudo apt full-upgrade
