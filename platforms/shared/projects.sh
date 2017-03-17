#!/bin/bash
set -e

projects=(barcommands)
project_root="$HOME/Projects"

mkdir -p "$project_root"

for project in $projects; do
  if [[ ! -d "${project_root}/${project}" ]]; then
    echo -n "Checking out ${project}"
    git clone "git@github.com:Mange/${project}" "${project_root}/${project}"
  fi
done

# barcommands
if [[ ! -e ~/.cargo/bin/bar-memory ]]; then
  echo "Installing barcommands"
  (cd "${project_root}/barcommands" && cargo install --force)
fi
