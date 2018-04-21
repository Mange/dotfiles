extern crate pathdiff;

use std::borrow::Cow;
use std::path::{Path, PathBuf};
use std::ffi::OsString;
use std::{fs, io};

use self::pathdiff::diff_paths;

use prelude::*;

#[derive(Debug)]
pub enum InstallationState {
    Installed,
    NotInstalled,
    BrokenSymlink(PathBuf),
    Conflict(PathBuf),
}

#[derive(Debug)]
pub struct ConfigDirectory {
    source_dir: PathBuf,
    dest_dir: PathBuf,
}

#[derive(Debug)]
pub struct Dotfile {
    source_path: PathBuf,
    dest_path: PathBuf,
}

pub trait Installable: Sized {
    fn source_path(&self) -> &Path;
    fn destination_path(&self) -> &Path;
    fn new_from_path(path: PathBuf, state: &State) -> Result<Self, Error>;

    fn all_in_dir(dir: &Path, state: &State) -> Result<Vec<Self>, Error> {
        dir.read_dir()?
            .map(|entry| {
                let entry = entry?;
                Self::new_from_path(entry.path(), state)
            })
            .collect()
    }

    fn symlink_target(&self) -> Cow<Path> {
        // TODO: Add some tests for this
        let destination_directory = self.destination_path().parent().unwrap();
        diff_paths(self.source_path(), destination_directory)
            .map(Cow::Owned)
            .unwrap_or_else(|| Cow::Borrowed(self.source_path()))
    }

    fn name_string_lossy(&self) -> Cow<str> {
        self.source_path().to_string_lossy()
    }

    fn state(&self) -> Result<InstallationState, Error> {
        let dest_path = self.destination_path();
        match dest_path.symlink_metadata() {
            Ok(metadata) => {
                if metadata.file_type().is_symlink() {
                    let mut link_destination = dest_path.read_link()?;
                    // If link is relative ("../foo"), then calculate the real path based on the
                    // directory the symlink lives in.
                    if !link_destination.is_absolute() {
                        // As we know it's a symlink it must be inside of something, so unwrapping
                        // the parent should be safe. Path::parent returns None when the path is a
                        // root path.
                        let symlink_parent = dest_path.parent().unwrap();
                        link_destination = symlink_parent.join(link_destination);
                    }
                    link_destination = link_destination.canonicalize()?;

                    if link_destination == self.source_path().canonicalize()? {
                        Ok(InstallationState::Installed)
                    } else if !link_destination.exists() {
                        Ok(InstallationState::BrokenSymlink(link_destination))
                    } else {
                        Ok(InstallationState::Conflict(link_destination))
                    }
                } else {
                    Ok(InstallationState::Conflict(dest_path.to_path_buf()))
                }
            }
            Err(ref err) if err.kind() == io::ErrorKind::NotFound => {
                Ok(InstallationState::NotInstalled)
            }
            Err(err) => Err(err.into()),
        }
    }

    fn install(&self) -> Result<(), Error> {
        let dest_path = self.destination_path();
        match fs::remove_file(&dest_path) {
            Ok(_) => {}
            Err(ref err) if err.kind() == io::ErrorKind::NotFound => {}
            Err(err) => {
                return Err(err)
                    .context(format!(
                        "Could not remove destination path at {}",
                        dest_path.display(),
                    ))
                    .map_err(Error::from)
            }
        };

        ::std::os::unix::fs::symlink(self.symlink_target().as_ref(), dest_path)?;
        Ok(())
    }
}

impl Installable for ConfigDirectory {
    fn source_path(&self) -> &Path {
        &self.source_dir
    }

    fn destination_path(&self) -> &Path {
        &self.dest_dir
    }

    fn new_from_path(path: PathBuf, state: &State) -> Result<Self, Error> {
        let name = path.file_name()
            .ok_or_else(|| format_err!("Entry at {} had no file name", path.display()))?
            .to_owned();

        Ok(ConfigDirectory {
            dest_dir: state.xdg_config_home().join(&name),
            source_dir: path,
        })
    }
}

impl Installable for Dotfile {
    fn source_path(&self) -> &Path {
        &self.source_path
    }

    fn destination_path(&self) -> &Path {
        &self.dest_path
    }

    fn new_from_path(path: PathBuf, state: &State) -> Result<Self, Error> {
        let name = {
            let base_name = path.file_name()
                .ok_or_else(|| format_err!("Entry at {} had no file name", path.display()))?;
            let mut name = OsString::with_capacity(base_name.len() + 1);
            name.push(".");
            name.push(base_name);
            name
        };

        Ok(Dotfile {
            dest_path: state.home().join(&name),
            source_path: path,
        })
    }
}
