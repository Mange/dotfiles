#!/usr/bin/env bash

stop-existing() {
  killall --quiet --wait --user $USER polybar
}

start-bars() {
  polybar top &
  polybar bottom &
}

hidpi-settings() {
  export POLYBAR_FONT_0="DejaVu Sans Mono:size=16;1"
  export POLYBAR_FONT_1="FontAwesome:size=16;1"
  export POLYBAR_FONT_2="PowerlineSymbols:size=16;1"
  # Devicons is named icomoon in the font file
  export POLYBAR_FONT_3="icomoon:size=16;1"
  export POLYBAR_BAR_HEIGHT=36
}

normal-settings() {
  export POLYBAR_FONT_0="DejaVu Sans Mono:size=10;2"
  export POLYBAR_FONT_1="FontAwesome:size=8;2"
  export POLYBAR_FONT_2="PowerlineSymbols:size=8;2"
  # Devicons is named icomoon in the font file
  export POLYBAR_FONT_3="icomoon:size=8;2"
  export POLYBAR_BAR_HEIGHT=26
}

start-on-hidpi() {
  local input_name="${1}"
  echo "Starting top and bottom bars on ${input_name} (HiDPI)"
  (hidpi-settings; export MONITOR="${input_name}"; start-bars)
}

start-on-normal() {
  local input_name="${1}"
  echo "Starting top and bottom bars on ${input_name} (normal)"
  (normal-settings; export MONITOR="${input_name}"; start-bars)
}

start-on-each-screen() {
  local input_name resolution height

  xrandr --listactivemonitors | tail -n +2 | \
    while read line; do
      # $line now looks like this:
      #  0: +*DP-1 2560/598x1440/336+0+0  DP-1
      input_name=$(echo ${line} | awk '{ print $4 }')
      # Extract full resolution part, then remove the "/598" and "/336+0+0" parts.
      resolution=$(echo ${line} | awk '{ print $3 }' | sed 's#/[^x]*##g')

      # Guess that we are on an HiDPI screen depending on screen height
      height=$(echo ${resolution} | cut -d 'x' -f 2)
      if [[ ${height} > 2000 ]]; then
        start-on-hidpi "${input_name}"
      else
        start-on-normal "${input_name}"
      fi
    done
}

stop-existing
start-on-each-screen
