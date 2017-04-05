#!/bin/bash
set -e

projects=(barcommands)
project_root="$HOME/Projects"

mkdir -p "$project_root"

for project in $projects; do
  if [[ ! -d "${project_root}/${project}" ]]; then
    echo "Checking out ${project}"
    git clone "git@github.com:Mange/${project}" "${project_root}/${project}"
  else
    echo "Updating ${project}"
    (cd "${project_root}/${project}" && git pull --ff-only)
  fi
done

# barcommands
echo "Installing barcommands"
(cd "${project_root}/barcommands" && cargo install --force)
