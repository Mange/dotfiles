#!/usr/bin/env bash
# Initial install
set -e
dotfiles_root="$(readlink --canonicalize "$(dirname "$0")")"

echo ":: Compiling binary"
(cd "${dotfiles_root}/dotfiles" && cargo build --release)

echo ":: Recording repo root in config"
mkdir -p "${dotfiles_root}/config/dotfiles"
echo "$dotfiles_root" > "${dotfiles_root}/config/dotfiles/path"

echo ":: Installing everything"
"${dotfiles_root}/dotfiles/target/release/dotfiles" --root "${dotfiles_root}" all