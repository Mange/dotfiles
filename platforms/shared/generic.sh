# shellcheck shell=bash

create-user-dirs() {
  # shellcheck source=/dev/null
  source "./shared/user-dirs.dirs"

  for var in \
    XDG_DESKTOP_DIR XDG_DOCUMENTS_DIR XDG_DOWNLOAD_DIR \
    XDG_MUSIC_DIR XDG_PICTURES_DIR XDG_PUBLICSHARE_DIR \
    XDG_TEMPLATES_DIR XDG_VIDEOS_DIR; do
    if [[ ! -d "${!var}" ]]; then
      echo "${!var} does not exist. Create it?"
      echo "Create ${!var}? [Yn] "
      read -r answer </dev/tty
      if [[ -z $answer || $answer = "y" || $answer = "Y" ]]; then
        mkdir -vp "${!var}"
      fi
    fi
  done
}
