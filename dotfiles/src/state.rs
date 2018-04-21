use std::env;
use std::path::{Path, PathBuf};
use failure::{Error, ResultExt};

#[derive(Debug)]
pub struct State {
    home_path: PathBuf,
    root_path: PathBuf,

    xdg_config_home: PathBuf,
    xdg_data_home: PathBuf,
}

fn determine_root() -> Result<PathBuf, Error> {
    let exe_path = env::current_exe().context("Could not find program path")?;
    // In development, it's common to run this command from within the nested dotfiles directory.
    // Scan up to find the first directory with a README.md file.
    let mut root_path = exe_path.parent().unwrap();
    loop {
        if root_path.join("README.md").is_file() {
            return Ok(root_path.into());
        }
        match root_path.parent() {
            Some(parent) => root_path = parent,
            None => {
                return Err(format_err!(
                    "Could not find any directory containing a README.md file from {}",
                    exe_path.display()
                ))
            }
        }
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
    pub fn new() -> Result<State, Error> {
        let home =
            env::home_dir().ok_or_else(|| format_err!("Could not determine home directory"))?;
        Ok(State {
            root_path: determine_root().context("Could not determine root path")?,
            xdg_config_home: determine_xdg_config_home(&home)
                .context("Could not determine XDG_CONFIG_HOME")?,
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
