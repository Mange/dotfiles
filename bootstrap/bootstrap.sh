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

bootstrap_script=https://raw.githubusercontent.com/Mange/dotfiles/master/bootstrap/bootstrap.yml

setup_arch() {
  pacman -Syu --noconfirm
  pacman -S --noconfirm --needed \
    sudo ansible curl

  if [[ ! -f /root/bootstrap.yml ]]; then
    curl -o /root/bootstrap.yml "$bootstrap_script"
  fi

  ansible-playbook \
    --connection=local --inventory localhost, \
    "/root/bootstrap.yml"

  cat <<EOF
Welcome. You should now set the password for your user:
    passwd mange

After that, log in as it and apply the dotfiles project.
    sudo su mange
    cd Projects/dotfiles
    ./setup.sh
EOF
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
