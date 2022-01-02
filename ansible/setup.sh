#!/bin/sh
set -e

if [ "$1" = "--help" ]; then
  echo "Usage: $0 [ansible-playbook options]"
  echo ""
  echo "Sets up the current machine."
  exit 0
fi

setup_arch() {
  if ! hash ansible-playbook >/dev/null 2>/dev/null; then
    sudo pacman -S --noconfirm --needed ansible
  fi
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

dir="$(dirname "$(readlink -f "$0")")"
cd "$dir"

echo "Running ansible bootstrap…"
ansible-galaxy collection install -r requirements.yml
ansible-playbook -i hosts environment.yml --ask-become-pass "$@"
