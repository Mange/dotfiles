#[macro_use]
extern crate clap;

#[macro_use]
extern crate failure;

#[macro_use]
extern crate log;

extern crate pest;
#[macro_use]
extern crate pest_derive;

mod config;
mod state;
mod logger;
mod manifest;

use std::path::Path;

use clap::{App, AppSettings, Arg, SubCommand};
use failure::{Error, ResultExt};

use config::{BinFile, ConfigDirectory, DataDirectory, FindInDir, Installable, InstallationState};
use state::State;
use logger::Logger;
use manifest::Manifest;

mod prelude {
    pub use failure::{Error, ResultExt};
    pub use state::State;
}

fn define_app<'a, 'b>() -> App<'a, 'b> {
    app_from_crate!()
        .setting(AppSettings::GlobalVersion)
        .setting(AppSettings::ColoredHelp)
        .setting(AppSettings::VersionlessSubcommands)
        .arg(
            Arg::with_name("verbose")
                .global(true)
                .short("v")
                .long("verbose")
                .help("Enables more verbose text output"),
        )
        .subcommand(
            SubCommand::with_name("install").about("Install all dotfiles where they should be."),
        )
        .subcommand(SubCommand::with_name("cleanup").about("Clean up broken symlinks in $HOME."))
        .subcommand(SubCommand::with_name("post").about("Runs post.sh script."))
        .subcommand(
            SubCommand::with_name("all")
                .about("(DEFAULT) Runs cleanup, install and post commands."),
        )
}

fn main() {
    Logger::init();

    match run() {
        Ok(_) => {}
        Err(error) => {
            let mut message = String::new();
            let mut indentation = 0;
            for (index, cause) in error.causes().enumerate() {
                for _ in 0..indentation {
                    message.push_str("  ");
                }

                if index == 0 {
                    message.push_str(&format!("{}\n", cause));
                } else {
                    message.push_str(&format!("Caused by: {}\n", cause));
                }

                indentation += 1;
            }

            error!("{}", message);
            ::std::process::exit(1);
        }
    }
}

fn run() -> Result<(), Error> {
    let app = define_app();
    let matches = app.get_matches();
    let state = State::new()?;

    if matches.is_present("verbose") {
        Logger::change_level(log::LevelFilter::Debug);
    } else {
        Logger::change_level(log::LevelFilter::Info);
    }

    match matches.subcommand() {
        ("install", Some(_)) => install(&state, true),
        ("cleanup", Some(_)) => cleanup(&state, true),
        ("post", Some(_)) => run_post(&state, true),
        ("all", Some(_)) | ("", None) => run_all(&state),
        (other, _) => {
            return Err(format_err!("{} subcommand is not yet implemented.", other));
        }
    }
}

/// Run all the subcommands.
fn run_all(state: &State) -> Result<(), Error> {
    cleanup(state, false)
        .and_then(|_| install(state, false))
        .and_then(|_| run_post(state, false))
}

/// Install dotfiles.
fn install(state: &State, _called_explicitly: bool) -> Result<(), Error> {
    debug!("Installing dotfiles…");
    let config_dir = state.root().join("config");
    let data_dir = state.root().join("data");
    let bin_dir = state.root().join("bin");
    let snowflake_manifest_path = state.root().join("snowflakes").join("manifest.txt");

    let configs = ConfigDirectory::all_in_dir(&config_dir, state)
        .context("Could not load list of config entries")?;
    let data_entries =
        DataDirectory::all_in_dir(&data_dir, state).context("Could not load list of data entries")?;
    let bins = BinFile::all_in_dir(&bin_dir, state)?;

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

fn install_targets<T: Installable>(targets: &[T]) -> Result<(), Error> {
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

fn install_target<T: Installable>(entry: &T) -> Result<(), Error> {
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

/// Delete broken symlinks from `$HOME`, etc.
fn cleanup(state: &State, called_explicitly: bool) -> Result<(), Error> {
    use std::fs;

    debug!("Cleaning up $HOME…");
    let mut cleaned = 0;

    for entry in state.home().read_dir()? {
        let entry = entry?;
        let path = entry.path();
        let metadata = path.symlink_metadata()?;
        if metadata.file_type().is_symlink() && !path.exists() {
            let dest = path.read_link()?;
            warn!(
                "Deleting broken symlink {} ({})",
                path.display(),
                dest.display()
            );
            fs::remove_file(path)?;
            cleaned += 1;
        }
    }

    if cleaned > 0 {
        info!("Cleaned {} file(s)", cleaned);
    } else if called_explicitly {
        info!("Nothing to clean up :)");
    }
    Ok(())
}

/// Runs post.sh file if it exists.
fn run_post(state: &State, called_explicitly: bool) -> Result<(), Error> {
    use std::process;
    let post_file = state.root().join("post.sh");

    if post_file.exists() {
        debug!("Running {}", post_file.display());
        match process::Command::new(post_file)
            .current_dir(state.root())
            .status()
        {
            Ok(status) if status.success() => {
                debug!("Command finished successfully");
                Ok(())
            }
            Ok(status) => Err(format_err!(
                "Command failed with exit status {}",
                status.code().unwrap_or(0)
            )),
            Err(error) => Err(error)
                .context("post.sh script failed")
                .map_err(Error::from),
        }
    } else {
        let message = format!(
            "Cannot find post.sh file ({} does not exist)",
            post_file.display()
        );
        if called_explicitly {
            Err(format_err!("{}", message))
        } else {
            warn!("{}", message);
            Ok(())
        }
    }
}
