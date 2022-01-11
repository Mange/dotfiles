#!/bin/sh
set -e

if [ "$1" = "--help" ]; then
  echo "Usage: $0 [ansible-playbook options]"
  echo ""
  echo "Sets up the current machine."
  exit 0
fi

dir="$(dirname "$(readlink -f "$0")")"
cd "$dir"
eval "$(bin/dotfiles --env)"

exec bin/dotfiles-setup
