#!/bin/bash
set -e

if [ ! -d "$HOME/.rvm" ]; then
  header "Installing RVM"
  \curl -sSL https://get.rvm.io | bash -s stable
fi

