extern crate dirs;
use clap::ArgMatches;
use failure::{Error, ResultExt};
use std::fs::File;
use std::io::Read;
use std::path::{Path, PathBuf};

#[derive(Debug)]
pub struct State {
    home_path: PathBuf,
    root_path: PathBuf,

    xdg_config_home: PathBuf,
    xdg_data_home: PathBuf,
}

fn load_root_path(xdg_config_path: &Path) -> Result<PathBuf, Error> {
    let path_file = xdg_config_path.join("dotfiles").join("path");
    if path_file.is_file() {
        let mut file = File::open(&path_file)
            .map_err(Error::from)
            .with_context(|_| format!("Failed to open config file {}", path_file.display()))?;

        let mut contents = String::new();
        file.read_to_string(&mut contents)
            .map_err(Error::from)
            .with_context(|_| format!("Failed to read config file {}", path_file.display()))?;

        Ok(PathBuf::from(contents.trim_right_matches('\n')))
    } else {
        Err(
            format_err!(
                "Could not find the project root. Please specify the --root option or create a config file at {}",
                path_file.display()
            )
        )
    }
}

fn determine_xdg_config_home() -> Result<PathBuf, Error> {
    match dirs::config_dir() {
        Some(path) => {
            if path.is_dir() {
                Ok(path)
            } else {
                Err(format_err!("{} is not a directory", path.display()))
            }
        }
        None => Err(format_err!("Could not determine config dir")),
    }
}

fn determine_xdg_data_home() -> Result<PathBuf, Error> {
    match dirs::data_local_dir() {
        Some(path) => {
            if path.is_dir() {
                Ok(path)
            } else {
                Err(format_err!("{} is not a directory", path.display()))
            }
        }
        None => Err(format_err!("Could not determine local data dir")),
    }
}

impl State {
    pub fn new(args: &ArgMatches) -> Result<State, Error> {
        let home =
            dirs::home_dir().ok_or_else(|| format_err!("Could not determine home directory"))?;

        let xdg_config_home = determine_xdg_config_home()?;

        let root_path = match args.value_of("root") {
            Some(path) => PathBuf::from(path),
            None => load_root_path(&xdg_config_home).context("Could not determine root path")?,
        };

        if !root_path.is_dir() {
            return Err(format_err!(
                "Specified root path {} is not a directory",
                root_path.display()
            ));
        }

        Ok(State {
            root_path,
            xdg_config_home,
            xdg_data_home: determine_xdg_data_home()?,
            home_path: home,
        })
    }

    pub fn root(&self) -> &Path {
        &self.root_path
    }

    pub fn home(&self) -> &Path {
        &self.home_path
    }

    pub fn xdg_config_home(&self) -> &Path {
        &self.xdg_config_home
    }

    pub fn xdg_data_home(&self) -> &Path {
        &self.xdg_data_home
    }
}
