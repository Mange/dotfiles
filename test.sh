#!/bin/sh
set -e

if [ "$1" = "--help" ] || [ "$#" -eq 0 ]; then
  echo "Usage: $0 <platform>"
  echo ""
  echo "Test the setup of <platform> using Docker."
  echo ""
  echo "Known platforms:"
  echo "- arch"
  [ "$1" = "--help" ] && exit 0
  exit 1
fi

platform="$1"
case "$platform" in
arch)
  docker build -t dotfiles-arch -f test/Dockerfile.arch .
  exec docker run \
    --rm -ti \
    --volume "$(pwd)/ansible:/home/mange/Projects/dotfiles/ansible" \
    dotfiles-arch \
    zsh
  ;;
*)
  echo "Unknown platform $platform"
  exit 1
  ;;
esac
