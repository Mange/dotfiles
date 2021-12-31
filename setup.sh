#!/bin/sh
set -e

if [ "$1" = "--help" ]; then
  echo "Usage: $0"
  echo ""
  echo "Sets up the current machine."
  exit 0
fi

setup_arch() {
  sudo pacman -S --noconfirm --needed ansible
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

echo "Running ansible bootstrap…"
ansible-galaxy collection install -r "${dir}/ansible/requirements.yml"
ansible-playbook \
  -i "${dir}/ansible/hosts" \
  "${dir}/ansible/environment.yml" \
  --ask-become-pass
