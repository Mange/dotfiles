#!/bin/bash
# Allow testing awesome config using awmtt
# See: https://github.com/serialoverflow/awmtt

if ! hash awmtt 2>/dev/null; then
  echo "Install awmtt first!" >&2
  exit 1
fi

export IN_AWMTT=yes

case "$1" in
  --help)
    echo "Usage: $0 <start | restart | stop | dev>"
    exit 0
    ;;
  start)
    awmtt start
    ;;
  restart)
    awmtt restart
    ;;
  stop)
    awmtt stop
    ;;
  dev)
    awmtt start
    watchexec -ce lua -- awmtt restart
    awmtt stop
    ;;
  *)
    echo "Unknown command: $1"
    exit 1
    ;;
esac
