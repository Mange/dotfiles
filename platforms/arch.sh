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

PACMAN="sudo pacman --noconfirm"
HOSTNAME="$(hostname --short)"

usage() {
  cat <<USAGE
USAGE: $0 [OPTIONS]

OPTIONS:
  --help
    Display this help text.

  --only SECTION, -o SECTION
    Only run the stuff part of that section.

    SECTIONS:
      all      (All sections)
      fast     (Only fast sections; no updates or installs)
      updates  (Installing updates)

      aur      (Install AUR software and tools)
      neovim   (Neovim support)
      pacman   (Install software)
      pip      (Install software based on python pip)
      npm      (Install software based on Node.js NPM)
      lua      (Lua setup)
      rust     (Rust setup)
      ruby     (Ruby setup)
USAGE
}
ONLY_SECTION="all"

if ! OPTS="$(getopt -n "$0" --longoptions "help,only:" --options "o:" --shell bash -- "$@")"; then
  exit 1
fi
eval set -- "$OPTS"

while true; do
  case "$1" in
  --help)
    usage
    shift
    exit 0
    ;;
  -o | --only)
    ONLY_SECTION="$2"
    shift 2
    ;;
  --)
    shift
    break
    ;;
  *)
    break
    ;;
  esac
done

case "$ONLY_SECTION" in
all | pacman | rust | projects | neovim | aur | updates | fast | pip | npm | ruby | lua)
  # Valid; do nothing
  ;;
*)
  echo "ERROR: $ONLY_SECTION is not a known section" >&2
  usage
  exit 1
  ;;
esac

run-section() {
  local name="$1"
  if [[ "$ONLY_SECTION" == "all" || "$ONLY_SECTION" == "$name" ]]; then
    return 0
  else
    return 1
  fi
}

install-npm-software() {
  header "Installing NPM software"

  wanted_software=(
    dockerfile-language-server-nodejs
  )

  if [[ $HOSTNAME == krista ]]; then
    wanted_software+=(toggl-cli)
  fi

  for package in "${wanted_software[@]}"; do
    if npm list -g "$package" >/dev/null 2>/dev/null; then
      run-command-quietly "Upgrading $package" < <(
        sudo npm upgrade -g "$package" 2>&1
      )
    else
      run-command-quietly "Installing $package" < <(
        sudo npm install -g "$package" 2>&1
      )
    fi
  done
}

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

enable-user-systemd-unit() {
  if [[ $(systemctl is-enabled --user "$1") != "enabled" ]] || [[ $(systemctl is-active --user "$1") != "active" ]]; then
    run-command-quietly "Starting and enabling $1 at login" < <(
      systemctl enable --user --now "$1" 2>&1
    )
  fi
}

disable-user-systemd-unit() {
  if [[ $(systemctl is-enabled --user "$1") == "enabled" ]] || [[ $(systemctl is-active --user "$1") == "active" ]]; then
    run-command-quietly "Stopping and disabling $1 at login" < <(
      sudo systemctl disable --user --now "$1" 2>&1
    )
  fi
}

if run-section "fast"; then
  header "Setting up GPG"
  setup-gpg-auto-retrieve
fi

# Rust is sometimes used to build things in AUR, install before AUR stuff.
if run-section "rust" || run-section "updates"; then
  install-rustup-components || handle-failure
fi
if run-section "rust"; then
  install-crates rust/crates.txt "Rust software" || handle-failure
  cargo-update || handle-failure
fi

if run-section "lua"; then
  header "Lua setup and packages (AwesomeWM, etc.)"

  # Skip lua setup if Awesome is not installed.
  if hash awesome 2>/dev/null; then
    if ! hash luarocks 2>/dev/null; then
      paru -S luarocks || handle-failure "Installing luarocks"
    fi

    if ! luarocks --lua-version 5.3 show moses 2>/dev/null >/dev/null; then
      run-command-quietly "luarocks install moses" < <(
        sudo luarocks --lua-version 5.3 install moses
      ) || handle-failure "Installing moses"
    fi
  else
    echo "(Skipping because AwesomeWM is not installed)"
  fi
fi

if run-section "ruby"; then
  header "Ruby setup and packages"
  install-ruby-via-rvm || handle-failure "Installing Ruby"
  install-global-ruby-gem "standard"
  install-global-ruby-gem "solargraph"
fi

if run-section "npm"; then
  install-npm-software || handle-failure "Installing NodeJS NPM software"
fi

if run-section "fast"; then
  setup-nerd-fonts || handle-failure "Installing Nerd Font overrides"
fi

if run-section "neovim"; then
  if hash nvim 2>/dev/null; then
    header "Neovim"

    run-command-quietly "Python 2 plugin" < <(
      if hash pip2 2>/dev/null; then
        pip2 install --user --upgrade --upgrade-strategy eager -q neovim 2>&1
      else
        echo "pip2 not installed!"
        exit 1
      fi
    )

    run-command-quietly "Python 3 plugin" < <(
      if hash pip3 2>/dev/null; then
        pip3 install --user --upgrade --upgrade-strategy eager -q neovim 2>&1
      else
        echo "pip3 not installed!"
        exit 1
      fi
    )

    run-command-quietly "Ruby plugin" < <(
      if hash gem 2>/dev/null; then
        gem install -q neovim 2>&1
      else
        echo "Ruby/gem not installed"
        exit 1
      fi
    )

    run-command-quietly "NodeJS plugin" < <(
      if hash npm 2>/dev/null; then
        sudo npm install -g neovim 2>&1
      else
        echo "npm not installed"
        exit 1
      fi
    )
  fi
fi

if run-section "fast"; then
  if hash gsettings 2>/dev/null; then
    gsettings set org.gnome.desktop.background show-desktop-icons false
  fi

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

  header "Configuring Systemd"
  enable-systemd-unit "NetworkManager"
  enable-systemd-unit "lightdm"
  enable-systemd-unit "bluetooth"
  enable-systemd-unit "sshd"
  enable-systemd-unit "tailscaled"
  enable-systemd-unit "pcscd" # smartcard daemon, for Yubikey, etc.

  if hash docker 2>/dev/null; then
    enable-systemd-unit "docker"
  fi

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

  enable-user-systemd-unit "redshift"
  disable-user-systemd-unit "spotifyd"

  if [[ $HOSTNAME == "morbidus" ]]; then
    enable-systemd-unit avahi-daemon
  fi

  sudo systemctl daemon-reload
fi

if run-section "updates"; then
  header "Installing updates"
  subheader "Installing AUR updates"
  if confirm "Really install all AUR updates now?" "n"; then
    paru -Sua || handle-failure
  fi

  subheader "Installing package updates"
  if confirm "Really install all updates now?" "n"; then
    $PACMAN -Su
  fi
fi

if run-section "updates" || run-section "ruby"; then
  subheader "Installing RVM/Ruby updates"
  update-global-ruby-gem "standard"
  update-global-ruby-gem "solargraph"
fi

echo ""
