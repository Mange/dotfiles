#[macro_use]
extern crate clap;

#[macro_use]
extern crate failure;

#[macro_use]
extern crate log;

mod config;
mod state;
mod logger;

use clap::{App, AppSettings, Arg, ArgMatches, SubCommand};
use failure::{Error, ResultExt};

use config::{BinFile, ConfigDirectory, DataDirectory, Dotfile, Installable, InstallationState};
use state::State;
use logger::Logger;

mod prelude {
    pub use failure::{Error, ResultExt};
    pub use clap::ArgMatches;
    pub use state::State;
}

fn define_app<'a, 'b>() -> App<'a, 'b> {
    app_from_crate!()
        .setting(AppSettings::GlobalVersion)
        .setting(AppSettings::ColoredHelp)
        .setting(AppSettings::SubcommandRequiredElseHelp)
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
        ("install", Some(matches)) => install(&state, matches),
        ("cleanup", Some(matches)) => cleanup(&state, matches),
        (other, _) => {
            return Err(format_err!("{} subcommand is not yet implemented.", other));
        }
    }
}

/// Install dotfiles.
fn install(state: &State, _matches: &ArgMatches) -> Result<(), Error> {
    debug!("Installing dotfiles…");
    let config_dir = state.root().join("config");
    let data_dir = state.root().join("data");
    let snowflake_dir = state.root().join("snowflakes");
    let bin_dir = state.root().join("bin");

    let configs = ConfigDirectory::all_in_dir(&config_dir, state)
        .context("Could not load list of config entries")?;
    let data_entries =
        DataDirectory::all_in_dir(&data_dir, state).context("Could not load list of data entries")?;
    let snowflakes =
        Dotfile::all_in_dir(&snowflake_dir, state).context("Could not load list of dotfiles")?;
    let bins = BinFile::all_in_dir(&bin_dir, state)?;

    install_entries(&configs)?;
    install_entries(&data_entries)?;
    install_entries(&snowflakes)?;
    install_entries(&bins)?;

    Ok(())
}

fn install_entries<T: Installable>(entries: &[T]) -> Result<(), Error> {
    entries.into_iter().map(install_entry).collect()
}

fn install_entry<T: Installable>(entry: &T) -> Result<(), Error> {
    let state = entry.state().context(format!(
        "Could not determine installation state for {}",
        entry.display_name(),
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
fn cleanup(state: &State, _matches: &ArgMatches) -> Result<(), Error> {
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
    } else {
        info!("Nothing to clean up :)");
    }
    Ok(())
}
