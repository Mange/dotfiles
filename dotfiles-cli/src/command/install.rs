use std::path::Path;

use target::{InstallationState, Target};
use files;
use manifest::Manifest;
use prelude::*;

/// Install dotfiles.
pub fn run(state: &State, _called_explicitly: bool) -> Result<(), Error> {
    debug!("Installing dotfiles…");
    let config_dir = state.root().join("config");
    let data_dir = state.root().join("data");
    let bin_dir = state.root().join("bin");
    let snowflake_manifest_path = state.root().join("snowflakes").join("manifest.txt");

    let configs = files::config_directories(&config_dir, state)
        .context("Could not load list of config entries")?;
    let data_entries =
        files::data_directories(&data_dir, state).context("Could not load list of data entries")?;
    let bins = files::bin_files(&bin_dir, state)?;

    install_targets(&configs)?;
    install_targets(&data_entries)?;
    install_targets(&bins)?;
    install_via_manifest(&snowflake_manifest_path)?;

    Ok(())
}

fn install_via_manifest(manifest_path: &Path) -> Result<(), Error> {
    use manifest::TargetError;

    let manifest = Manifest::load(manifest_path)?;
    for entry in manifest.entries() {
        match entry.installable_targets() {
            Ok(targets) => {
                if targets.len() > 0 {
                    install_targets(&targets)?
                } else {
                    warn!("No targets found for {}", entry);
                }
            }
            Err(error) => match error {
                TargetError::SourceNotFound => {
                    return Err(format_err!("Could not find {}", entry));
                }
                TargetError::DestinationIsNotDirectory(dest) => {
                    error!(
                        "Skipping {} because it already exists and is not a directory",
                        dest.display()
                    );
                }
                TargetError::InvalidGlob(pattern, error) => {
                    return Err(error)
                        .context(format!("Could not process glob {:?}", pattern))
                        .map_err(Error::from);
                }
                TargetError::GlobIterationError(error) => {
                    return Err(error)
                        .context(format!("Could not process {}", entry))
                        .map_err(Error::from);
                }
            },
        }
    }

    Ok(())
}

fn install_targets(targets: &[Target]) -> Result<(), Error> {
    targets
        .into_iter()
        .map(|target| {
            install_target(target)
                .with_context(|_| {
                    format!(
                        "Could not install {} to {}",
                        target.source_path().display(),
                        target.destination_path().display()
                    )
                })
                .map_err(Error::from)
        })
        .collect()
}

fn install_target(entry: &Target) -> Result<(), Error> {
    let state = entry.state().context(format!(
        "Could not determine installation state for {}",
        entry.destination_path().display(),
    ))?;
    let name = entry.display_name();

    match state {
        InstallationState::Installed => {
            debug!("Skipping entry \"{}\": Already installed", name);
        }
        InstallationState::NotInstalled => {
            info!("Installing entry \"{}\"", name);
            entry.install()?
        }
        InstallationState::BrokenSymlink(old_dest) => {
            warn!(
                "Entry \"{}\" is currently a broken symlink to {}. The symlink will be overwritten.",
                name,
                old_dest.display()
            );
            info!("Installing entry \"{}\"", name);
            entry.install()?
        }
        InstallationState::Conflict(other) => {
            error!(
                "Cannot install entry \"{}\": Conflict with existing file at {}",
                entry.display_name(),
                other.display()
            );
        }
    }

    Ok(())
}
