#!/bin/bash
set -e

if [[ "$(id -u)" -eq 0 ]]; then
	echo "Must not be run as root!" >&2
	exit 127
fi

cd "$(dirname "$0")"
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
      rust     (Rust setup)
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
  all | pacman | rust | projects | neovim | aur | updates | fast | pip | npm )
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

install-pacman() {
  local filename="$1"
  local wanted_software wanted_packages installed_packages needed

  wanted_software=$(sed 's/\s*#.*$//' "$filename" | sed '/^$/d' | sort)

  # See if everything is already installed by resolving all the packages
  # (groups and indvidual) into their individual packages. Then filter them
  # through the local package database to get a list of "missing" software.
  wanted_packages=$(set +e; echo "$wanted_software" | pacman -Sp --print-format "%n" - | sort)
  installed_packages=$(set +e; echo "$wanted_packages" | pacman -Q - 2>/dev/null | awk '{ print $1 }' | sort)
  needed="$(comm -23 <(echo "$wanted_packages") <(echo "$installed_packages"))"

  if [[ -n "$needed" ]]; then
    subheader "Installing new software:"
    echo "$needed" | column
    # --needed does not reinstall already installed software. Just to be safe.
    set +e
    echo "$red"
    run-command-quietly "" < <(
      echo "$needed" | $PACMAN -S --quiet --needed - 2>&1
    )
    set -e
  else
    echo "${green}Everything installed ✔${reset}"
  fi
}

uninstall-pacman() {
  local filename="$1"
  local unwanted unwanted_packages installed_packages to_uninstall

  unwanted=$(sed 's/#.*$//' "$filename" | sed '/^$/d' | sort)

  # Filter out unknown package names (most likely packages installed through AUR
  # and then removed).
  unwanted_packages=()
  for pkg in $unwanted; do
    # Find exact matches of the package name
    if pacman -S --quiet -s "$pkg" | grep --quiet "^${pkg}$" ; then
      unwanted_packages+=("$pkg")
    fi
  done

  if [[ "${#unwanted_packages[@]}" -eq 0 ]]; then
    echo "${green}Everything uninstalled ✔${reset}"
    return
  fi

  installed_packages=$(set +e; echo "${unwanted_packages[@]}" | pacman -Q - 2>/dev/null | awk '{ print $1 }' | sort)
  to_uninstall="$(comm -12 <(echo "${unwanted_packages[@]}" | sort) <(echo "$installed_packages"))"

  if [[ -n "$to_uninstall" ]]; then
    subheader "Uninstalling software:"
    echo "$to_uninstall" | column
    set +e
    echo "$red"

    run-command-quietly "" < <(
      echo "$to_uninstall" | $PACMAN -Rs - 2>&1
    )

    # Remove from aur repo; in case it was there.
    for pkg in $to_uninstall; do
      repo-remove -q /var/cache/pacman/custom/custom.db.tar "$pkg"
    done

    set -e
  else
    echo "${green}Everything uninstalled ✔${reset}"
  fi
}

compile-install-aur() {
  local filename="$1"
  local installed=0
  local errors=0

  # NOTE: This `while` has its stdin set at the end of the loop body so it does
  # not run in a subshell, so it can modify $errors and $installed.
  while read -r package; do
    # Skip if already installed
    if pacman -Q --quiet "$package" 2>/dev/null >/dev/null; then
      continue
    fi

    if run-command-quietly "Compiling package $package" < <(
      aur sync --no-view --no-confirm "$package" 2>&1
    ); then
      if run-command-quietly "Installing package $package" < <(
        $PACMAN -S --quiet --needed "$package" 2>&1
      ); then
        installed=$((installed + 1))
      else
        errors=$((errors + 1))
      fi
    else
      errors=$((errors + 1))
    fi

  done < <(sed 's/#.*$//' "$filename" | sed '/^$/d')

  if [[ $errors -eq 0 ]]; then
    echo "${green}Everything compiled/installed ✔${reset}"
  else
    echo "${yellow}${errors} package(s) failed to install. ${installed} installed successfully.${reset}"
    handle-failure
  fi
}

install-pip-software() {
    header "Installing PIP software"

    wanted_software=(
      pgcli
    )

    for package in "${wanted_software[@]}"; do
      if pip show "$package" >/dev/null 2>/dev/null; then
        run-command-quietly "Upgrading $package" < <(
          pip install --user --upgrade "$package" 2>&1
        )
      else
        run-command-quietly "Installing $package" < <(
          pip install --user "$package" 2>&1
        )
      fi
    done
}

install-npm-software() {
    header "Installing NPM software"

    wanted_software=()

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

compile-aurutils() {
    header "Installing aurutils"

    subheader "Download and install from source"
    if [[ ! -d /opt/aurutils ]]; then
      sudo mkdir -p "/opt"
      sudo git clone https://aur.archlinux.org/aurutils.git /opt/aurutils
    fi

    sudo chown -R "$USER:$USER" /opt/aurutils
    sudo chmod -R u+wX /opt/aurutils
    gpg --recv-keys 6bc26a17b9b7018a

    # Install dependencies
    sudo pacman -S --needed expac diffstat

    (cd /opt/aurutils; makepkg -i)

    subheader "Setting up local repository"
    if [[ ! -f /etc/pacman.d/custom ]]; then
      echo "Generating /etc/pacman.d/custom"
      cat <<EOF | sudo tee /etc/pacman.d/custom > /dev/null
[options]
CacheDir = /var/cache/pacman/pkg
CacheDir = /var/cache/pacman/custom
CleanMethod = KeepCurrent

[custom]
SigLevel = Optional TrustAll
Server = file:///var/cache/pacman/custom
EOF
    fi

    if ! grep -q "/etc/pacman.d/custom" /etc/pacman.conf; then
      echo "Adding include statement to /etc/pacman.conf"
      echo -e '\n\nInclude = /etc/pacman.d/custom' | sudo tee --append /etc/pacman.conf > /dev/null
    fi

    if [[ ! -d /var/cache/pacman/custom ]]; then
      echo "Generating repo at specified location"
      sudo install -d /var/cache/pacman/custom -o "$USER"
      repo-add /var/cache/pacman/custom/custom.db.tar
      $PACMAN -Syu
    fi

    subheader "Installing aurutils using aurutils (whoa!)"
    aur sync --no-view --no-confirm aurutils

    subheader "Cleaning up source"
    sudo rm -rf /opt/aurutils
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
    echo "Warning: confirm-diff got two identical files '${old}' '${new}'" > /dev/stderr
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
    init-sudo
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

init-sudo() {
  # Ask for password up front
  sudo echo > /dev/null
}

if run-section "fast"; then
  header "Setting up GPG"
  setup-gpg-auto-retrieve
fi

if run-section "updates" || run-section "pacman"; then
  init-sudo

  header "Refreshing pacman cache"
  run-command-quietly "Refreshing pacman" < <(
    $PACMAN -S --refresh --quiet 2>&1
  )
fi

if run-section "pacman" || run-section "fast"; then
  header "Uninstall deprecated software"
  uninstall-pacman "arch/uninstall.txt" || handle-failure
fi

if run-section "pacman"; then
  for bundle in base "${HOSTNAME}" my; do
    bundle_file="arch/${bundle}.txt"
    if [[ -f $bundle_file ]]; then
      header "Install ${bundle} software"
      install-pacman "${bundle_file}" || handle-failure
    fi
  done

  header "Ruby setup and packages"
  install-ruby-via-rvm || handle-failure "Installing Ruby"
  install-global-ruby-gem "ripper-tags"
  install-global-ruby-gem "solargraph"
fi

if run-section "aur"; then
  if ! hash aur 2>/dev/null; then
    init-sudo
    compile-aurutils || handle-failure
  fi

  if hash aur 2>/dev/null; then
    init-sudo
    header "Compile and install AUR software"
    compile-install-aur arch/aur.txt || handle-failure

    if [[ -f "arch/${HOSTNAME}-aur.txt" ]]; then
      header "Compile and install AUR software for ${HOSTNAME}"
      compile-install-aur "arch/${HOSTNAME}-aur.txt" || handle-failure
    fi
  fi
fi

if run-section "pip"; then
  init-sudo
  install-pip-software || handle-failure "Installing Python PIP software"
fi

if run-section "npm"; then
  init-sudo
  install-npm-software || handle-failure "Installing NodeJS NPM software"
fi

if run-section "fast"; then
  setup-nerd-fonts || handle-failure "Installing Nerd Font overrides"
fi

if run-section "rust"; then
  install-or-update-rustup || handle-failure
  install-rustup-components || handle-failure
  install-crates rust/crates.txt "Rust software" || handle-failure
  install-nightly-crates rust/nightly-crates.txt "Nightly Rust software" || handle-failure
  cargo-update || handle-failure
fi

if run-section "neovim"; then
  if hash nvim 2>/dev/null; then
    header "Neovim"
    init-sudo

    run-command-quietly "Python 2 plugin" < <(
      if hash pip2 2>/dev/null; then
        sudo pip2 install --user --upgrade --upgrade-strategy eager -q neovim 2>&1
      else
        echo "pip2 not installed!"
        exit 1
      fi
    )

    run-command-quietly "Python 3 plugin" < <(
      if hash pip3 2>/dev/null; then
        sudo pip3 install --user --upgrade --upgrade-strategy eager -q neovim 2>&1
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
        # Install both on hardcoded system path and in current nvm environment.
        sudo npm install -g neovim 2>&1
        [[ -f /usr/bin/npm ]] && sudo /usr/bin/npm install -g neovim 2>&1
      else
        echo "npm not installed"
        exit 1
      fi
    )
  fi
fi

if run-section "all"; then
  init-sudo
  install-fzf || handle-failure
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

  header "Setting up wallpapers"
  sudo rsync --archive --delete ../data/wallpapers/ /usr/share/wallpapers/Mange || handle-failure "running rsync"
  sudo chown -R root:root /usr/share/wallpapers/Mange

  configure-lightdm
  configure-polkit

  header "Configuring Systemd"
  enable-systemd-unit "NetworkManager"
  enable-systemd-unit "lightdm"
  enable-systemd-unit "bluetooth"
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
    aur sync --no-view --no-confirm -u || handle-failure
  fi

  subheader "Installing package updates"
  if confirm "Really install all updates now?" "n"; then
    $PACMAN -Su
  fi

  subheader "Installing RVM/Ruby updates"
  update-global-ruby-gem "ripper-tags"
  update-global-ruby-gem "solargraph"
fi

echo ""
