#!/bin/bash
set -e

if [ ! -d "$HOME/Music/Radio/DI" ]; then
  header "Downloading radio playlists"
  mkdir -p "$HOME/Music/Radio/DI"
  ../bin/di-download
fi
