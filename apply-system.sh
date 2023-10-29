#!/usr/bin/env sh

mode=switch

case "$1" in
switch | boot | test)
  mode="$1"
  shift
  ;;
esac

exec sudo nixos-rebuild "$mode" --flake ".#$(uname -n)" "$@"
