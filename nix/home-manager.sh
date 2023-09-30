#!/usr/bin/env sh

exec home-manager --flake ".#${USER}@$(uname -n)" "$@"
