#!/usr/bin/env bash
# Run this script as root after you have rebooted into a new Arch machine. Run
# as root, as you don't have a user account yet.
#
# The script will create your user, install dependencies of the dotfiles and
# then clone the dotfiles and let the normal platform script take over.

if [[ $(whoami) != root ]]; then
  echo "You need to run this script as root." >/dev/stderr
  exit 1
fi

confirm-continue() {
  echo -n "${1}. Continue? [yN]: " >/dev/stderr
  read -r answer
  if [[ $answer == "y" || $answer == "Y" ]]; then
    return 0
  else
    echo "Aborting" >/dev/stderr
    exit 0
  fi
}

# Ask for user to create
echo -n "Username of new user [mange]: " >/dev/stderr
read -r username
if [[ -z "$username" ]]; then
  username=mange
fi

set -e
set -o pipefail

# Install git and zsh (because user should switch to it)
(set -x; pacman -Sy --needed --quiet git zsh)

# Create user, if it does not exist
if id "$username" >/dev/null 2>/dev/null; then
  confirm-continue "User $username already exists"
else
  echo ">> Creating $username" >/dev/stderr
  (
    set -x
    useradd --create-home --shell "$(which zsh)" --user-group "$username"

    # Allow full name to be set
    chfn "$username"

    # Set password
    passwd "$username"
  )
fi

if ! groups "$username" | grep -qE '\bwheel\b'; then
  echo ">> Adding $username to wheel group (sudoers)" >/dev/stderr
  (set -x; gpasswd -a "$username" wheel)
fi

if ! groups "$username" | grep -qE '\bvideo\b'; then
  echo ">> Adding $username to video group (control brightness)" >/dev/stderr
  (set -x; gpasswd -a "$username" video)
fi

if ! groups "$username" | grep -qE '\binput\b'; then
  echo ">> Adding $username to input group (control LEDs)" >/dev/stderr
  (set -x; gpasswd -a "$username" input)
fi

if ! groups "$username" | grep -qE '\bdocker\b'; then
  echo ">> Adding $username to docker group" >/dev/stderr
  # groupadd --force exits with 0 even if group alrady exists
  (set -x; groupadd --force docker; gpasswd -a "$username" docker)
fi

if ! grep -qE '^%wheel ALL' /etc/sudoers; then
  echo ">> Enabling wheel group for sudoers" >/dev/stderr
  echo "This is not done automatically for safety reasons..." >/dev/stderr
  confirm-continue "Uncomment the line for \"%wheel\""
  visudo
fi

# Add structure to user's home directory
home=$(getent passwd "$username" | cut -d ':' -f 6)
if [[ ! -d "$home" ]]; then
  echo "Something went wrong! $home does not exist!" >/dev/stderr
  exit 1
fi

projects_dir="${home}/Projects"
if [[ ! -d "$projects_dir" ]]; then
  (
    set -x
    mkdir "$projects_dir"
    chown "${username}:${username}" "$projects_dir"
  )
fi

# Clone dotfiles
# Run using normal bash shell to prevent any ZSH config guides to kick in or
# anything like that. Also, this is a script and not an interactive session and
# I use bash for scripts and ZSH for interactive sessions anyway.
if [[ ! -d "${projects_dir}/dotfiles" ]]; then
  (
    set -x
    su --login --shell "$SHELL" --command="git clone https://github.com/Mange/dotfiles \"${projects_dir}/dotfiles\"" - mange
  )
fi

# Run platform script
set +e
echo "Running platform script as $username" >/dev/stderr
# Using sudo since it deals with interactive sessions better, and also nested sudo calls.
if ! sudo --login --user="$username" -- "${projects_dir}/dotfiles/platforms/arch.sh"; then
  echo "Script failed!" >/dev/stderr
  confirm-continue "Please rerun it as $username at a later time"
fi

# Print a TODO list
cat <<-EOF >/dev/stderr

===============================================================================
All done!

You can now log in as your new user. At the end of this message you can do it
automatically in this shell.

Things you now need to do in order to fully bootstrap the system:

  1. Get your password manager up and running.
  2. Add important devices/folders to syncthing (especially Security).
  3. Log in to Firefox to sync things.
  4. Change the upstream of the dotfiles repo to SSH if you want to be able to
     push changes to them.

Enjoy your new computer!
===============================================================================
EOF

confirm-continue "Will now log in as $username"
exec su --login - "$username"
