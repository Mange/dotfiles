#[macro_use]
extern crate clap;

#[macro_use]
extern crate failure;

#[macro_use]
extern crate log;

extern crate pest;
#[macro_use]
extern crate pest_derive;

mod command;
mod files;
mod logger;
mod manifest;
mod state;
mod target;

use clap::{App, AppSettings, Arg, SubCommand};
use failure::Error;

use state::State;
use logger::Logger;

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
        ("install", Some(_)) => command::install(&state, true),
        ("cleanup", Some(_)) => command::cleanup(&state, true),
        ("post", Some(_)) => command::post(&state, true),
        ("all", Some(_)) | ("", None) => command::all(&state),
        (other, _) => {
            return Err(format_err!("{} subcommand is not yet implemented.", other));
        }
    }
}
