#!/usr/bin/env bash
set -e

usage() {
  cat <<EOF
Usage: $0 [options]

Updates dotfiles.

Options:
  -t <TAG>
    Only update ansible tag TAG. Can be specified multiple times.

EOF
}

tags=()
skip_tags=(bootstrap)

while [[ "$#" -gt 0 ]]; do
  case "$1" in
  --help)
    usage
    exit 0
    ;;
  -t)
    shift
    tags+=("$1")
    if [[ "$1" == "bootstrap" ]]; then
      skip_tags=()
    fi
    shift
    ;;
  *)
    echo "Unknown option $1" >&2
    echo "" >&2
    usage >&2
    exit 1
    ;;
  esac
done

dir="$(dirname "$(readlink -f "$0")")"

ansible_options=(
  -i "${dir}/ansible/hosts"
  "${dir}/ansible/environment.yml"
  --ask-become-pass
)

if [[ "${#skip_tags}" -gt 0 ]]; then
  ansible_options+=(--skip-tags "$(
    IFS=","
    echo "${skip_tags[*]}"
  )")
fi

if [[ "${#tags}" -gt 0 ]]; then
  ansible_options+=(-t "$(
    IFS=","
    echo "${tags[*]}"
  )")
fi

echo "Running ansible bootstrap…"
ansible-galaxy collection install -r "${dir}/ansible/requirements.yml"
ansible-playbook "${ansible_options[@]}"
