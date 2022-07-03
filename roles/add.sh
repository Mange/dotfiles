#!/bin/sh
set -e

name="$1"

cd "$(dirname "$(readlink -f "$0")")"

case "$name" in
group-* | host-*)
  mkdir -pv "$name/meta"
  printf -- "---\ndependencies:\n" >"$name/meta/main.yml"
  ;;
*)
  mkdir -pv "$name/tasks"
  cat >"$name/tasks/main.yml" <<EOF
# yaml-language-server: \$schema=https://raw.githubusercontent.com/ansible-community/schemas/main/f/ansible-tasks.json
- tags: $name
  block:
EOF
  ;;
esac
