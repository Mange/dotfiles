#!/bin/sh
set -ex

sudo nix-channel --update
nix-channel --update
nix flake update
