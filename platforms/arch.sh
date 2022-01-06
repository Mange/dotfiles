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

header "Ruby setup and packages"
install-ruby-via-rvm || handle-failure "Installing Ruby"

if ! timedatectl show | grep -q "^NTP=yes"; then
  subheader "Enabling timesync (NTP)"
  sudo timedatectl set-ntp true
fi
