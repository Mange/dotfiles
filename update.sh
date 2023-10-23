#!/bin/sh
set -ex

nix-channel --update
nix flake update
