#!/usr/bin/env sh

exec sudo nixos-rebuild switch --flake ".#$(uname -n)" "$@"
