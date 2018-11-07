#!/usr/bin/env bash

stop-existing() {
  killall --quiet --wait --user "$USER" polybar
}

start-bars() {
  local is_primary="${1}"
  if [[ $is_primary == "yes" ]]; then
    polybar primary &
  else
    polybar secondary &
  fi
}

hidpi-settings() {
  export POLYBAR_FONT_0="Symbols Nerd Font:size=16;0"
  export POLYBAR_FONT_1="Fira Sans Regular:size=16;0"
  export POLYBAR_BAR_HEIGHT=36
  export POLYBAR_TRAY_SIZE=32
  export POLYBAR_TRAY_SCALE=1.2
}

normal-settings() {
  export POLYBAR_FONT_0="Symbols Nerd Font:size=10;0"
  export POLYBAR_FONT_1="Fira Sans Regular:size=10;0"
  export POLYBAR_BAR_HEIGHT=26
  export POLYBAR_TRAY_SIZE=24
  export POLYBAR_TRAY_SCALE=1.0
}

machine-settings() {
  local filename
  filename="$(dirname "$0")/machine-$(hostname --short).env"

  if [[ -f $filename ]]; then
    export $(grep -Ev "\\s*#" "$filename" | xargs)
  fi
}

start-on-hidpi() {
  local input_name="${1}"
  local is_primary="${2}"
  echo "Starting bar(s) on ${input_name} (HiDPI)"
  (hidpi-settings; machine-settings; export MONITOR="${input_name}"; start-bars "$is_primary")
}

start-on-normal() {
  local input_name="${1}"
  local is_primary="${2}"
  echo "Starting bar(s) on ${input_name} (normal)"
  (normal-settings; machine-settings; export MONITOR="${input_name}"; start-bars "$is_primary")
}

start-on-each-screen() {
  local input_name resolution height

  xrandr --listactivemonitors | tail -n +2 | \
    while read -r line; do
      # $line now looks like this:
      #  0: +*DP-1 2560/598x1440/336+0+0  DP-1
      input_name=$(echo "${line}" | awk '{ print $4 }')
      # Extract full resolution part, then remove the "/598" and "/336+0+0" parts.
      resolution=$(echo "${line}" | awk '{ print $3 }' | sed 's#/[^x]*##g')
      # Primary marker ("*") shows if this is the primary screen
      is_primary=$(echo "${line}" | awk '{ print $2 }' | grep -q '\*' && echo "yes")

      # Guess that we are on an HiDPI screen depending on screen height
      height=$(echo "${resolution}" | cut -d 'x' -f 2)
      if [[ ${height} -gt 2000 ]]; then
        start-on-hidpi "${input_name}" "${is_primary}"
      else
        start-on-normal "${input_name}" "${is_primary}"
      fi
    done
}

stop-existing
start-on-each-screen
