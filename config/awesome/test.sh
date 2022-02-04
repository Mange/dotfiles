#!/bin/bash
# Allow testing awesome config using awmtt and luaunit
# See: https://github.com/serialoverflow/awmtt
set -e

function usage() {
  cat <<USAGE
Usage: $0 [options] <commands…>

Commands:
  - dev
    Start AWMTT and restart Awesome on every Lua file change if tests pass.
    Interrupt and AWMTT will be shut down as well.

  - luaunit
    Runs all luaunit tests.

  - setup
    Installs needed dependencies.

Low-level commands:
  - start
    Start AWMTT to have a preview window of Awesome running.

  - stop
    Stops the currently running AWMTT instance.

  - restart
    Restart awesome inside AWMTT.

  - iteration
    What is run in the "dev" watcher script. Runs all unit tests, and if they
    pass, AWMTT is restarted.
USAGE
}

run_setup() {
  sudo luarocks --lua-version 5.3 install luaunit

  if ! hash awmtt 2>/dev/null; then
    paru -S awmtt
  fi
}

run_luaunit() {
  lua5.4 tests.lua
}

export IN_AWMTT=yes

if [[ "$#" -eq 0 ]]; then
  usage
  exit 1
fi

while [[ "$#" -ge 1 ]]; do
  case "$1" in
  --help)
    usage
    exit 0
    ;;
  start)
    shift
    awmtt start
    ;;
  restart)
    shift
    awmtt restart
    ;;
  stop)
    shift
    awmtt stop
    ;;
  setup)
    shift
    run_setup
    ;;
  luaunit)
    shift
    run_luaunit
    ;;
  iteration)
    shift
    (run_luaunit && awmtt restart) || true
    ;;
  dev)
    shift
    awmtt start
    set +e
    watchexec -ce lua -- "$0" iteration
    set -e
    awmtt stop
    ;;
  *)
    echo "Unknown command or option: $1" >&2
    usage >&2
    exit 1
    ;;
  esac
done
