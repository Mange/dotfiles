use std::borrow::Cow;
use std::path::{Path, PathBuf};
use std::ffi::{OsStr, OsString};
use std::{fs, io};
use prelude::*;

#[derive(Debug)]
pub struct Config {
    name: OsString,
    source_dir: PathBuf,
    dest_dir: PathBuf,
}

#[derive(Debug)]
pub enum InstallationState {
    Installed,
    NotInstalled,
    BrokenSymlink,
    Conflict(PathBuf),
}

impl Config {
    pub fn all_in_dir(dir: &Path, state: &State) -> Result<Vec<Config>, Error> {
        dir.read_dir()?
            .map(|entry| {
                let entry = entry?;
                Config::new_from_path(entry.path(), state)
            })
            .collect()
    }

    fn new_from_path(path: PathBuf, state: &State) -> Result<Config, Error> {
        let name = path.file_name()
            .ok_or_else(|| format_err!("Entry at {} had no file name", path.display()))?
            .to_owned();
        Ok(Config {
            dest_dir: state.xdg_config_home().join(&name),
            name: name,
            source_dir: path,
        })
    }

    pub fn state(&self) -> Result<InstallationState, Error> {
        match self.dest_dir.symlink_metadata() {
            Ok(metadata) => {
                if metadata.file_type().is_symlink() {
                    let link_destination = self.dest_dir.read_link()?;
                    if link_destination == self.source_dir {
                        Ok(InstallationState::Installed)
                    } else {
                        Ok(InstallationState::Conflict(link_destination))
                    }
                } else {
                    Ok(InstallationState::Conflict(self.dest_dir.clone()))
                }
            }
            Err(ref err) if err.kind() == io::ErrorKind::NotFound => {
                Ok(InstallationState::NotInstalled)
            }
            Err(err) => Err(err.into()),
        }
    }

    pub fn name(&self) -> &OsStr {
        &self.name
    }

    pub fn name_string_lossy(&self) -> Cow<str> {
        self.name.to_string_lossy()
    }

    pub fn install(self) -> Result<(), Error> {
        match fs::remove_file(&self.dest_dir) {
            Ok(_) => {}
            Err(ref err) if err.kind() == io::ErrorKind::NotFound => {}
            Err(err) => {
                return Err(err)
                    .context(format!(
                        "Could not remove destination path at {}",
                        self.dest_dir.display(),
                    ))
                    .map_err(Error::from)
            }
        };

        ::std::os::unix::fs::symlink(&self.source_dir, &self.dest_dir)?;
        Ok(())
    }
}
