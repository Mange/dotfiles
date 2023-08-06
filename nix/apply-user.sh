#!/usr/bin/env sh

exec home-manager switch --flake ".#${USER}@$(uname -n)"
