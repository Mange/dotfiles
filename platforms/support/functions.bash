#!/bin/bash

export reset=`tput sgr0`
export black=`tput setaf 0`
export red=`tput setaf 1`
export green=`tput setaf 2`
export yellow=`tput setaf 3`
export blue=`tput setaf 4`
export magenta=`tput setaf 5`
export cyan=`tput setaf 6`
export white=`tput setaf 7`

overline() {
  printf "%0.s‾" `eval echo {1..$1}`
}
export -f overline

header() {
  echo
  if [[ $BASH_VERSION < 4 ]]; then
    # Mac OS comes with a very old version of bash
    # No uppercase for me.
    local message="$1"
  else
    local message="${1^^}"
  fi
  echo "$yellow‣ $green${message}$reset"
  echo -n $yellow
  overline $((${#1} + 2))
  echo $reset
}
export -f header
