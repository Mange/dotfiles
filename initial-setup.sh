#!/usr/bin/env bash
# Initial install
set -e
dotfiles_root="$(readlink --canonicalize "$(dirname "$0")")"

# shellcheck source=/dev/null
source "${dotfiles_root}/config/shells/xdg_zealotry"

mkdir -p "${XDG_CONFIG_HOME}"
mkdir -p "${XDG_DATA_HOME}"
mkdir -p "${XDG_CACHE_HOME}"

echo ":: Compiling CLI"
(cd "${dotfiles_root}/dotfiles-cli" && cargo build --release)

echo ":: Recording repo root in config"
mkdir -p "${dotfiles_root}/config/dotfiles"
echo "$dotfiles_root" > "${dotfiles_root}/config/dotfiles/path"

echo ":: Installing everything"
"${dotfiles_root}/dotfiles-cli/target/release/dotfiles" --root "${dotfiles_root}" all
