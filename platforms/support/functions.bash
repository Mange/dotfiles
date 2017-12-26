#!/bin/bash

export reset=$(set +e; tput sgr0)
export black=$(set +e; tput setaf 0)
export red=$(set +e; tput setaf 1)
export green=$(set +e; tput setaf 2)
export yellow=$(set +e; tput setaf 3)
export blue=$(set +e; tput setaf 4)
export magenta=$(set +e; tput setaf 5)
export cyan=$(set +e; tput setaf 6)
export white=$(set +e; tput setaf 7)

overline() {
  printf "%0.s‾" `eval echo {1..$1}`
}
export -f overline

header() {
  echo
  if [[ "$BASH_VERSION" < "4" ]]; then
    # Mac OS comes with a very old version of bash
    # No uppercase for me.
    local message="$1"
  else
    local message="${1^^}"
  fi
  echo "${yellow}‣ ${green}${message}${reset}"
  echo -n "$yellow"
  overline $((${#1} + 2))
  echo "$reset"
}
export -f header

subheader() {
  echo
  local message="$1"
  echo "${yellow}‣ ${message}${reset}"
}
export -f subheader
