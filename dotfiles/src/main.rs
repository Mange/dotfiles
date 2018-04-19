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

use config::{Config, InstallationState};
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
        Logger::change_level(log::LevelFilter::Info);
    } else {
        Logger::change_level(log::LevelFilter::Warn);
    }

    match matches.subcommand() {
        ("install", Some(matches)) => install(&state, matches),
        (other, _) => {
            return Err(format_err!("{} subcommand is not yet implemented.", other));
        }
    }
}

fn install(state: &State, _matches: &ArgMatches) -> Result<(), Error> {
    info!("Installing dotfiles...");
    let config_dir = state.root().join("config");
    let configs =
        Config::all_in_dir(&config_dir, state).context("Could not load list of config files")?;
    for config in configs {
        let state = config.state().context(format!(
            "Could not determine installation state for {}",
            config.name_string_lossy(),
        ))?;
        let name = config.name_string_lossy();

        match state {
            InstallationState::Installed => {
                info!("Skipping config \"{}\": Already installed", name);
            }
            InstallationState::NotInstalled => {
                info!("Installing config \"{}\"", name);
                config.install()?
            }
            InstallationState::BrokenSymlink(old_dest) => {
                warn!(
                    "Config \"{}\" is currently a broken symlink to {}. The symlink will be overwritten.",
                    name,
                    old_dest.display()
                );
                info!("Installing config \"{}\"", name);
                config.install()?
            }
            InstallationState::Conflict(other) => {
                error!(
                    "Cannot install config \"{}\": Conflict with existing file at {}",
                    config.name_string_lossy(),
                    other.display()
                );
            }
        }
    }
    Ok(())
}
