#!/usr/bin/env bash
# Run after installing dotfiles to perform extra work.

if [[ "$SHELL" != *zsh ]]; then
  echo "Warning: You seem to be using a shell different from zsh (${SHELL})" >/dev/stderr
  echo "Fix this by running:" >/dev/stderr
  echo "  chsh -s \$(which zsh)" >/dev/stderr
fi
