#!/bin/bash
set -e

cd $(dirname $0)
. ./support/functions.bash

. ./shared/rvm.sh
. ./shared/rust.sh

pacman="sudo pacman --noconfirm"

install-pacman() {
  local filename="$1"
  local wanted_software=$(sed 's/#.*$//' "$filename" | sed '/^$/d' | sort)

  # See if everything is already installed by resolving all the packages
  # (groups and indvidual) into their individual packages. Then filter them
  # through the local package database to get a list of "missing" software.
  local wanted_packages=$(set +e; echo "$wanted_software" | pacman -Sp --print-format "%n" - | sort)
  local installed_packages=$(set +e; echo "$wanted_packages" | pacman -Q - | awk '{ print $1 }' | sort)
  local needed="$(comm -23 <(echo "$wanted_packages") <(echo "$installed_packages"))"

  if [[ -n "$needed" ]]; then
    echo "Installing:"
    echo "$needed" | column
    # --needed does not reinstall already installed software. Just to be safe.
    set +e
    echo $red
    output="$(echo "$needed" | $pacman -S --quiet --needed - 2>&1)"
    if [[ $? == 0 ]]; then
      echo -n $green ✔ $reset
    else
      echo $red ✘
      echo $output $reset
    fi
    echo $reset
    set -e
  else
    echo "${green}Everything installed ✔${reset}"
  fi
}

# Ask for password right away.
sudo echo > /dev/null

header "Refreshing pacman cache"
$pacman -S --refresh --quiet

for bundle in base $(hostname --short) my; do
  bundle_file="arch/${bundle}.txt"
  if [[ -f $bundle_file ]]; then
    header "Install ${bundle} software"
    install-pacman arch/base.txt || handle-failure
  fi
done
