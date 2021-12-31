#!/usr/bin/env bash
# Run this script as root after you have booted into a new machine.
#
# The script will get ansible up and running, clone the repo, and then run the
# bootstrap playbook.
set -e

if [ "$1" = "--help" ]; then
  echo "Usage: $0"
  echo ""
  echo "Sets up the current machine."
  exit 0
fi

if [[ $(whoami) != root ]]; then
  echo "You need to run this script as root." >/dev/stderr
  exit 1
fi

repo_url=https://github.com/Mange/dotfiles

setup_arch() {
  pacman -Syu --noconfirm
  pacman -S --noconfirm --needed \
    git sudo ansible

  dir="/root/dotfiles-bootstrap"

  if [[ ! -d "$dir" ]]; then
    git clone "$repo_url" "$dir"
  fi

  ansible-playbook -i "${dir}/ansible/hosts" "${dir}/bootstrap/bootstrap.yml"
  echo "Now you need to set a password for the user:"
  echo "  passwd mange"
}

case "$(uname -s)" in
Linux)
  if [ -f /etc/os-release ]; then
    dist=$(awk -F '=' '/^ID=/ { print $2 }' /etc/os-release)
    case "$dist" in
    arch*)
      setup_arch
      ;;
    *)
      echo "Not a supported dist: $dist"
      exit 1
      ;;
    esac
  fi
  ;;
*)
  echo "Not a supported system."
  exit 1
  ;;
esac
