#!/bin/sh
set -e

mode=reuse
platform=
hostname="${HOST:-$(hostname)}"

usage() {
  cat <<EOF
Usage: $0 [options] <platform>

Test the setup of <platform> using Docker.

Known platforms:
  - arch

Options:
  --rebuild
    Rebuild the container before starting it, even if it already exist.

  --host HOST, -h HOST
    Set hostname inside the container. Defaults to \"$hostname\".
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
  --help)
    shift
    usage
    exit 0
    ;;
  --rebuild)
    mode=rebuild
    shift
    ;;
  -h | --host | --hostname)
    shift
    hostname="$1"
    shift
    ;;
  arch)
    platform="$1"
    shift
    ;;
  *)
    echo "Unknown option: $1" >&2
    usage >&2
    exit 1
    ;;
  esac
done

if [ -z "$platform" ]; then
  echo "No platform specified" >&2
  usage >&2
  exit 1
fi

image_name="dotfiles-$platform"
container_name="dotfiles-$platform-run"

has_container() {
  count="$(docker ps --quiet --all --filter name="$1" | wc -l)"
  [ "$count" -gt 0 ]
}

if has_container "$container_name" && [ "$mode" = "reuse" ]; then
  exec docker start --interactive --attach "$container_name"
else
  docker build -t "$image_name" -f "test/Dockerfile.${platform}" .
  (has_container "$container_name" && docker rm "$container_name") || true

  exec docker run \
    -ti \
    --name "$container_name" \
    --hostname "$hostname" \
    --volume "$(pwd):/home/mange/Projects/dotfiles" \
    --volume "$(pwd)/bootstrap/bootstrap.yml:/root/bootstrap.yml" \
    "$image_name"
fi
