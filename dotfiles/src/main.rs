#[macro_use]
extern crate clap;

#[macro_use]
extern crate failure;

mod config;
mod state;

use clap::{App, AppSettings, ArgMatches, SubCommand};
use failure::{Error, ResultExt};

use config::{Config, InstallationState};
use state::State;

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
        .subcommand(
            SubCommand::with_name("install").about("Install all dotfiles where they should be."),
        )
}

fn main() {
    match run() {
        Ok(_) => {}
        Err(error) => {
            let mut indentation = 0;
            for (index, cause) in error.causes().enumerate() {
                for _ in 0..indentation {
                    eprint!("  ");
                }

                if index == 0 {
                    eprintln!("Error: {}", cause);
                } else {
                    eprintln!("Caused by: {}", cause);
                }

                indentation += 2;
            }

            ::std::process::exit(1);
        }
    }
}

fn run() -> Result<(), Error> {
    let app = define_app();
    let matches = app.get_matches();
    let state = State::new()?;

    match matches.subcommand() {
        ("install", Some(matches)) => install(&state, matches),
        (other, _) => {
            return Err(format_err!("{} subcommand is not yet implemented.", other));
        }
    }
}

fn install(state: &State, _matches: &ArgMatches) -> Result<(), Error> {
    let config_dir = state.root().join("config");
    let configs =
        Config::all_in_dir(&config_dir, state).context("Could not load list of config files")?;
    for config in configs {
        let state = config.state().context(format!(
            "Could not determine installation state for {}",
            config.name_string_lossy(),
        ))?;
        match state {
            InstallationState::Installed => {
                eprintln!("{} is already installed", config.name_string_lossy())
            }
            InstallationState::NotInstalled | InstallationState::BrokenSymlink => config.install()?,
            InstallationState::Conflict(other) => {
                eprintln!(
                    "Cannot install {} config: Conflict with existing file at {}",
                    config.name_string_lossy(),
                    other.display()
                );
            }
        }
    }
    Ok(())
}
