#!/bin/bash
set -e

cd $(dirname $0)
. ./support/functions.bash

. ./shared/generic.sh
. ./shared/rvm.sh
. ./shared/rust.sh

PACMAN="sudo pacman --noconfirm"

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
      neovim   (Neovim support)
      pacman   (Install software)
      projects (Personal projects)
      rust     (Rust setup)
USAGE
}
ONLY_SECTION="all"

OPTS=$(getopt -n "$0" --longoptions "help,only:" --options "o:" --shell bash -- "$@")
if [[ $? != 0 ]]; then exit 1; fi
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
  all | pacman | rust | projects | neovim )
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
  local wanted_software=$(sed 's/#.*$//' "$filename" | sed '/^$/d' | sort)

  # See if everything is already installed by resolving all the packages
  # (groups and indvidual) into their individual packages. Then filter them
  # through the local package database to get a list of "missing" software.
  local wanted_packages=$(set +e; echo "$wanted_software" | pacman -Sp --print-format "%n" - | sort)
  local installed_packages=$(set +e; echo "$wanted_packages" | pacman -Q - 2>/dev/null | awk '{ print $1 }' | sort)
  local needed="$(comm -23 <(echo "$wanted_packages") <(echo "$installed_packages"))"

  if [[ -n "$needed" ]]; then
    echo "Installing:"
    echo "$needed" | column
    # --needed does not reinstall already installed software. Just to be safe.
    set +e
    echo $red
    output="$(echo "$needed" | $PACMAN -S --quiet --needed - 2>&1)"
    if [[ $? == 0 ]]; then
      echo -n $green ✔ $reset
    else
      echo $red ✘
      echo $output $reset
    fi
    echo $reset
    set -e
  else
    echo "${green}Everything installed ✔${reset}"
  fi
}

init-sudo() {
  # Ask for password up front
  sudo echo > /dev/null
}

if run-section "pacman"; then
  init-sudo

  header "Refreshing pacman cache"
  $PACMAN -S --refresh --quiet

  for bundle in base $(hostname --short) my; do
    bundle_file="arch/${bundle}.txt"
    if [[ -f $bundle_file ]]; then
      header "Install ${bundle} software"
      install-pacman "${bundle_file}" || handle-failure
    fi
  done
fi

if run-section "rust"; then
  install-or-update-rustup || handle-failure
  install-rustup-components || handle-failure
  install-crates rust/crates.txt "Rust software" || handle-failure
  install-nightly-crates rust/nightly-crates.txt "Nightly Rust software" || handle-failure
  cargo-update || handle-failure
fi

if run-section "projects"; then
  ./shared/projects.sh || handle-failure
fi

if run-section "neovim"; then
  if hash nvim 2>/dev/null; then
    header "Neovim"
    init-sudo

    subheader "Python plugin"
    if hash pip 2>/dev/null; then
      sudo pip install -q neovim && echo "${green}✔ OK${reset}" || handle-failure
    else
      echo "${red}pip not installed${reset}"
    fi

    subheader "Ruby plugin"
    if hash gem 2>/dev/null; then
      gem install -q neovim && echo "${green}✔ OK${reset}" || handle-failure
    else
      echo "${red}Ruby/gem not installed${reset}"
    fi

    subheader "NodeJS plugin"
    if hash npm 2>/dev/null; then
      sudo npm install -g neovim && echo "${green}✔ OK${reset}" || handle-failure
    else
      echo "${red}npm not installed${reset}"
    fi
  fi
fi

if run-section "all"; then
  ./shared/di.sh || handle-failure
  install-fzf || handle-failure

  if hash gsettings 2>/dev/null; then
    gsettings set org.gnome.desktop.background show-desktop-icons false
  fi

  header "Installing updates"
  $PACMAN -Su
fi
