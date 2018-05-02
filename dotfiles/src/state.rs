use std::env;
use std::path::{Path, PathBuf};
use std::fs::File;
use std::io::Read;
use failure::{Error, ResultExt};
use clap::ArgMatches;

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

fn determine_xdg_config_home(home: &Path) -> Result<PathBuf, Error> {
    match env::var_os("XDG_CONFIG_HOME") {
        Some(var) => {
            let path = PathBuf::from(var);
            if path.is_dir() {
                Ok(path)
            } else {
                Err(format_err!(
                    "{} is not a directory (set in $XDG_CONFIG_HOME)",
                    path.display()
                ))
            }
        }
        None => Ok(home.join(".config").to_path_buf()),
    }
}

fn determine_xdg_data_home(home: &Path) -> Result<PathBuf, Error> {
    match env::var_os("XDG_DATA_HOME") {
        Some(var) => {
            let path = PathBuf::from(var);
            if path.is_dir() {
                Ok(path)
            } else {
                Err(format_err!(
                    "{} is not a directory (set in $XDG_DATA_HOME)",
                    path.display()
                ))
            }
        }
        None => Ok(home.join(".local").join("share").to_path_buf()),
    }
}

impl State {
    pub fn new(args: &ArgMatches) -> Result<State, Error> {
        let home =
            env::home_dir().ok_or_else(|| format_err!("Could not determine home directory"))?;

        let xdg_config_home =
            determine_xdg_config_home(&home).context("Could not determine XDG_CONFIG_HOME")?;

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
            xdg_data_home: determine_xdg_data_home(&home)
                .context("Could not determine XDG_DATA_HOME")?,
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
