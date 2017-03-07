#!/bin/bash
set -e

cd $(dirname $0)/..
. ./support/functions.bash
. ../gruvbox-colors.env

profile=$(dconf list /org/gnome/terminal/legacy/profiles:/ | head -n1)

if [[ $profile == "" ]]; then
  echo ${red}Could not find profile!${reset}
  exit 1
fi

set -x
dconf write "/org/gnome/terminal/legacy/profiles:/${profile}background-transparency-percent" "10"
dconf write "/org/gnome/terminal/legacy/profiles:/${profile}background-color" "'$dark0'"
dconf write "/org/gnome/terminal/legacy/profiles:/${profile}foreground-color" "'$light1'"

# Stolen from https://github.com/metalelf0/gnome-terminal-colors/blob/master/colors/gruvbox-dark/palette_dconf
dconf write "/org/gnome/terminal/legacy/profiles:/${profile}palette" "['#282828282828', '#cccc24241d1d', '#989897971a1a', '#d7d799992121', '#454585858888', '#b1b162628686', '#68689d9d6a6a', '#bdbdaeae9393', '#7c7c6f6f6464', '#fbfb49493434', '#b8b8bbbb2626', '#fafabdbd2f2f', '#8383a5a59898', '#d3d386869b9b', '#8e8ec0c07c7c', '#ebebdbdbb2b2']"
