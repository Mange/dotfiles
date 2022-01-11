#!/bin/bash
set -eu
if [[ ! -d "$GNUPGHOME" ]]; then
  mkdir -p "$(dirname "$GNUPGHOME")"

  # See if one exist in $HOME first and move it.
  if [[ -d "$HOME/.gnupg" ]]; then
    mv "$HOME/.gnupg" "$GNUPGHOME"
  else
    # Generate the GPG directory by running a command
    mkdir -p "$GNUPGHOME"
    gpg --list-keys
  fi

  if [[ ! -d "$GNUPGHOME" ]]; then
    echo "WARNING: Could not generate $GNUPGHOME directory!"
    exit 1
  fi
fi

if ! grep -qE "^keyserver-options auto-key-retrieve" "${GNUPGHOME}/gpg.conf" 2>/dev/null; then
  echo "keyserver-options auto-key-retrieve" >>"${GNUPGHOME}/gpg.conf"
fi
