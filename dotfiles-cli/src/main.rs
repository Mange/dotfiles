#[macro_use]
extern crate clap;

#[macro_use]
extern crate failure;

#[macro_use]
extern crate log;

extern crate pest;
#[macro_use]
extern crate pest_derive;

#[macro_use]
extern crate derive_builder;

extern crate dirs;

mod command;
mod files;
mod logger;
mod manifest;
mod state;
mod target;

use clap::{App, AppSettings, Arg, SubCommand};
use failure::Error;

use logger::Logger;
use state::State;

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
        .arg(
            Arg::with_name("root")
                .global(true)
                .takes_value(true)
                .value_name("DIR")
                .long("root")
                .help("Sets the root of the dotfiles repo.")
                .long_help("Sets the root of the dotfiles repo. It is read from $XDG_CONFIG_HOME/dotfiles/path by default."),
        )
        .subcommand(
            SubCommand::with_name("install").about("Install all dotfiles where they should be."),
        )
        .subcommand(SubCommand::with_name("cleanup").about("Clean up broken symlinks in installation directories."))
        .subcommand(SubCommand::with_name("post").about("Runs post.sh script."))
        .subcommand(SubCommand::with_name("self-update").about("Recompiles and installs this binary from sources."))
        .subcommand(
            SubCommand::with_name("all")
                .about("(DEFAULT) Runs self-update, cleanup, install and post commands."),
        )
}

fn main() {
    Logger::init();

    match run() {
        Ok(_) => {}
        Err(error) => {
            let mut message = String::new();

            message.push_str(&format!("{}\n", error));

            for (indentation, cause) in error.iter_causes().enumerate() {
                for _ in 0..indentation {
                    message.push_str("  ");
                }
                message.push_str(&format!("Caused by: {}\n", cause));
            }

            error!("{}", message);
            ::std::process::exit(1);
        }
    }
}

fn run() -> Result<(), Error> {
    let app = define_app();
    let matches = app.get_matches();

    if matches.is_present("verbose") {
        Logger::change_level(log::LevelFilter::Debug);
    } else {
        Logger::change_level(log::LevelFilter::Info);
    }

    let state = State::new(&matches)?;

    match matches.subcommand() {
        ("install", Some(_)) => command::install(&state, true),
        ("cleanup", Some(_)) => command::cleanup(&state, true),
        ("post", Some(_)) => command::post(&state, true),
        ("self-update", Some(_)) => command::self_update(&state, true),
        ("all", Some(_)) | ("", None) => command::all(&state),
        (other, _) => Err(format_err!("{} subcommand is not yet implemented.", other)),
    }
}
