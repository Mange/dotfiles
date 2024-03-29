# shellcheck source=/dev/null

die() {
  echo "$*"
  exit 1
}

export excludes_file="${XDG_CONFIG_HOME}/backup/excludes"
export passphrase_file="${XDG_CONFIG_HOME}/backup/passphrase.local"

if [[ -f "${XDG_CONFIG_HOME}/backup/options.local" ]]; then
  # shellcheck source=/dev/null
  source "${XDG_CONFIG_HOME}/backup/options.local"
else
  echo "No machine-specific backup configuration set. Aborting."
  exit 0
fi

# shellcheck disable=2154
if [[ -z "$backup_dir" ]]; then
  die "\$backup_dir not set"
fi

# shellcheck disable=2154
if [[ -n $mountpoint ]]; then
  # shellcheck disable=2154
  if [[ -z "$disk_uuid" ]]; then
    die "\$disk_uuid not set"
  fi

  if [[ ! -d "$mountpoint" ]]; then
    udiskie-mount "$disk_uuid" || die "Could not mount ${disk_uuid}"
  fi

  if [[ ! -d "$mountpoint" ]]; then
    die "Could not mount ${mountpoint}"
  fi
fi

if [[ ! -d "$backup_dir" ]]; then
  die "${backup_dir} does not exist"
fi

if [[ -f "$passphrase_file" ]]; then
  chown mange:mange "$passphrase_file"
  chmod u=r,go= "$passphrase_file"
else
  die "${passphrase_file} does not exist"
fi

export backup_url="file://${backup_dir}"
