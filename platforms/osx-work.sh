#!/bin/sh
set -e

cd $(dirname $0)

echo "::::::::::: INSTALLING WORK SOFTWARE :::::::::::"
brew bundle osx/Brewfile-work
