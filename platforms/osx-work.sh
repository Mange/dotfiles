#!/usr/bin/env bash
set -e

cd $(dirname $0)
. ./support/functions.bash

header "Installing work software"
./osx/brew-work.sh
