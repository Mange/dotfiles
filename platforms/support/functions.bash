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
  local message="${1^^}" # Uppercase message
  echo "${yellow}‣ ${green}${message}${reset}"
  echo -n "$yellow"
  overline $((${#1} + 2))
  echo "$reset"
}
export -f header

subheader() {
  echo
  local message="$1"
  shift
  echo "$@" "${yellow}‣ ${message}${reset}"
}
export -f subheader

handle-failure() {
  if [[ -n "$1" ]]; then
    echo "${red}Command failed: ${1}${reset} "
  else
    echo "${red}Command failed!${reset} "
  fi

  echo -n "Continue? [Yn] "
  read -r answer </dev/tty
  if [[ $answer != "" && $answer != "y" && $answer != "Y" ]]; then
    echo "Aborting"
    exit 1
  fi
}
export -f handle-failure

run-command-quietly() {
  local sub_pid=$!
  local sub_code=
  local caption="$1"
  local output

  if [[ -n "$caption" ]]; then
    subheader "$caption" -n
  fi
  echo -n "$red"

  output="$(cat -)"
  set +e
  wait "$sub_pid"
  sub_code=$?
  set -e

  if [[ $sub_code -eq 0 ]]; then
    echo -n "${green} ✔${reset}"
  else
    echo "${red} ✘"
    echo "${output}${reset}"
    handle-failure "${caption}"
  fi
  echo "$reset"

  return $sub_code
}
export -f run-command-quietly
