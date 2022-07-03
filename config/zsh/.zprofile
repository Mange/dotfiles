#!/bin/zsh
# Executed on login shells.

# Replace shell with X session if logging in to TTY1 (and no display server is
# running already, or else this would become an infinite loop…)
if [ -z "${DISPLAY}" ] && [ "$(tty)" = "/dev/tty1" ]; then

  # Make sure all environments and similar are setup properly. Especially
  # important for XAUTHORITY placement in XDG dir specification.
  # shellcheck source=/dev/null
  . "${XDG_CONFIG_HOME:-${HOME}/.config}/shells/xdg_zealotry"

  exec startx
fi
