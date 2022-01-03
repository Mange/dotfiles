#!/bin/bash
set -e

if [[ "$(id -u)" -eq 0 ]]; then
  echo "Must not be run as root!" >&2
  exit 127
fi

cd "$(dirname "$0")"

set -a
. ../config/environment.d/10-xdg-zealotry.conf
set +a

. ./support/functions.bash

. ./shared/generic.sh
. ./shared/rust.sh

copy-replace-with-diff() {
  local source="$1"
  local target="$2"

  # If file exists, and is not identical then ask the user if it should be
  # installed or not.
  if [[ -f "$target" ]]; then
    if is-identical-file "$target" "$source"; then
      return 0
    elif ! confirm-diff "$target" "$source"; then
      # Abort
      return 0
    fi
  fi

  cp "$source" "$target"
}

sudo-copy-replace-with-diff() {
  local source="$1"
  local target="$2"

  if [[ -f "$target" ]]; then
    if is-identical-file "$target" "$source"; then
      return 0
    elif ! confirm-diff "$target" "$source"; then
      # Abort
      return 0
    fi
  fi

  sudo cp "$source" "$target"
  sudo chown root:root "$target"
  sudo chmod u=rw,og=r "$target"
}

is-identical-file() {
  local a="$1"
  local b="$2"

  if diff -q "$a" "$b"; then
    return 0
  else
    return 1
  fi
}

confirm-diff() {
  local old="$1"
  local new="$2"

  local differ=diff

  if hash colordiff 2>/dev/null; then
    differ=colordiff
  fi

  if diff="$("${differ}" -u "${old}" "${new}" 2>&1)"; then
    echo "Warning: confirm-diff got two identical files '${old}' '${new}'" >/dev/stderr
    return 0
  else
    echo "${yellow}Installed file differs from repo file:${reset}"
    echo "${diff}"
    if confirm "Overwrite config?" "n"; then
      return 0
    else
      echo "${red}Aborting${reset}"
      return 1
    fi
  fi
}

confirm() {
  local message="${1}"
  local default="${2:-n}"
  local prompt
  if [[ $default == "y" ]]; then
    prompt="Yn"
  else
    prompt="yN"
  fi

  echo -n "${message} [${prompt}] "
  read -r answer </dev/tty
  if [[ $answer = "y" || $answer = "Y" ]]; then
    return 0
  elif [[ $answer = "n" || $answer = "N" ]]; then
    return 1
  else
    if [[ $default == "y" ]]; then
      return 0
    else
      return 1
    fi
  fi
}

configure-lightdm() {
  local config=/etc/lightdm/lightdm-gtk-greeter.conf
  local dotfile_config=shared/lightdm-gtk-greeter.conf

  header "Configuring LightDM"
  sudo-copy-replace-with-diff "$dotfile_config" "$config" || handle-failure
}

configure-polkit() {
  header "Configuring PolicyKit"

  local config=/etc/polkit-1/rules.d/blueman.rules
  local dotfile_config=./arch/polkit-blueman.rules

  sudo-copy-replace-with-diff "$dotfile_config" "$config" || handle-failure
}

setup-nerd-fonts() {
  local package_config=/etc/fonts/conf.avail/10-nerd-font-symbols.conf
  local user_config=${XDG_CONFIG_HOME:-~/.config}/fontconfig/conf.d/10-nerd-font-symbols.conf

  if [[ -f "$package_config" && ! -e "$user_config" ]]; then
    header "Setting up Nerd Fonts config for current user"
    mkdir -p "$(dirname "${user_config}")"
    ln -s "$package_config" "$user_config"
    fc-cache
  fi
}

enable-systemd-unit() {
  if [[ $(systemctl is-enabled "$1") != "enabled" ]] || [[ $(systemctl is-active "$1") != "active" ]]; then
    run-command-quietly "Starting and enabling $1 at boot" < <(
      sudo systemctl enable --now "$1" 2>&1
    )
  fi
}

# Rust is sometimes used to build things in AUR, install before AUR stuff.
install-rustup-components || handle-failure

install-crates rust/crates.txt "Rust software" || handle-failure
cargo-update || handle-failure

header "Ruby setup and packages"
install-ruby-via-rvm || handle-failure "Installing Ruby"

setup-nerd-fonts || handle-failure "Installing Nerd Font overrides"

header "Setting up user directories"
copy-replace-with-diff \
  "shared/user-dirs.dirs" \
  "$HOME/.config/user-dirs.dirs"
create-user-dirs

header "Setting up default apps"
xdg-mime default spacefm.desktop inode/directory

header "Setting up wallpapers"
sudo rsync --archive --delete ../data/wallpapers/ /usr/share/wallpapers/Mange || handle-failure "running rsync"
sudo chown -R root:root /usr/share/wallpapers/Mange

configure-lightdm
configure-polkit

sudo-copy-replace-with-diff \
  "shared/polkit/50-udiskie.rules" \
  "/etc/polkit-1/rules.d/50-udiskie.rules"

sudo-copy-replace-with-diff \
  "shared/duplicity-backup.service" \
  "/etc/systemd/system/duplicity-backup.service"
sudo-copy-replace-with-diff \
  "shared/duplicity-backup.timer" \
  "/etc/systemd/system/duplicity-backup.timer"
enable-systemd-unit "duplicity-backup.timer"

sudo-copy-replace-with-diff \
  "arch/download-pacman-updates.service" \
  "/etc/systemd/system/download-pacman-updates.service"
sudo-copy-replace-with-diff \
  "arch/download-pacman-updates.timer" \
  "/etc/systemd/system/download-pacman-updates.timer"
enable-systemd-unit "download-pacman-updates.timer"

if ! timedatectl show | grep -q "^NTP=yes"; then
  subheader "Enabling timesync (NTP)"
  sudo timedatectl set-ntp true
fi

sudo systemctl daemon-reload

echo ""
