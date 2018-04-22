extern crate pathdiff;

use std::borrow::Cow;
use std::path::{Path, PathBuf};
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

// TODO: Merge together all of these variants? Try to wait for bigger outliers to avoid picking the
// wrong abstraction.

#[derive(Debug)]
pub struct ConfigDirectory {
    name: String,
    source_dir: PathBuf,
    dest_dir: PathBuf,
}

#[derive(Debug)]
pub struct DataDirectory {
    name: String,
    source_dir: PathBuf,
    dest_dir: PathBuf,
}

#[derive(Debug)]
pub struct BinFile {
    name: String,
    source_path: PathBuf,
    dest_path: PathBuf,
}

#[derive(Debug)]
pub struct CustomTarget {
    name: String,
    source_path: PathBuf,
    dest_path: PathBuf,
    shell_callback: Option<String>,
}

pub trait Installable: Sized {
    fn source_path(&self) -> &Path;
    fn destination_path(&self) -> &Path;
    fn display_name(&self) -> &str;

    fn after_install_action(&self) -> Option<Result<(), Error>> {
        None
    }

    fn symlink_target(&self) -> Cow<Path> {
        // TODO: Add some tests for this
        let destination_directory = self.destination_path().parent().unwrap();
        diff_paths(self.source_path(), destination_directory)
            .map(Cow::Owned)
            .unwrap_or_else(|| Cow::Borrowed(self.source_path()))
    }

    fn state(&self) -> Result<InstallationState, Error> {
        let dest_path = self.destination_path();
        match dest_path.symlink_metadata() {
            Ok(metadata) => {
                if metadata.file_type().is_symlink() {
                    let mut link_destination = dest_path
                        .read_link()
                        .context("Could not read symlink destination")?;
                    // If link is relative ("../foo"), then calculate the real path based on the
                    // directory the symlink lives in.
                    if !link_destination.is_absolute() {
                        // As we know it's a symlink it must be inside of something, so unwrapping
                        // the parent should be safe. Path::parent returns None when the path is a
                        // root path.
                        let symlink_parent = dest_path.parent().unwrap();
                        link_destination = symlink_parent.join(link_destination);
                    }

                    if link_destination.exists() {
                        link_destination = link_destination
                            .canonicalize()
                            .context("Could not canonicalize the symlink")?;
                    }

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
        // dest_path will never be "/", so getting the parent should always work.
        let dest_dir = dest_path.parent().unwrap();

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

        if !dest_dir.exists() {
            fs::create_dir_all(dest_dir)?;
        }

        ::std::os::unix::fs::symlink(self.symlink_target().as_ref(), dest_path)?;

        if let Some(result) = self.after_install_action() {
            result.with_context(|_| format!("Failed to run callback for {}", self.display_name()))?;
        }

        Ok(())
    }
}

pub trait FindInDir: Sized {
    fn new_from_path(path: PathBuf, state: &State) -> Result<Self, Error>;

    fn all_in_dir(dir: &Path, state: &State) -> Result<Vec<Self>, Error> {
        dir.read_dir()?
            .map(|entry| {
                let entry = entry?;
                Self::new_from_path(entry.path(), state)
            })
            .collect()
    }
}

impl Installable for ConfigDirectory {
    fn source_path(&self) -> &Path {
        &self.source_dir
    }

    fn destination_path(&self) -> &Path {
        &self.dest_dir
    }

    fn display_name(&self) -> &str {
        &self.name
    }
}

impl FindInDir for ConfigDirectory {
    fn new_from_path(path: PathBuf, state: &State) -> Result<Self, Error> {
        let name = path.file_name()
            .ok_or_else(|| format_err!("Entry at {} had no file name", path.display()))?
            .to_owned();

        Ok(ConfigDirectory {
            name: format!("config/{}", name.to_string_lossy()),
            dest_dir: state.xdg_config_home().join(&name),
            source_dir: path,
        })
    }
}

impl Installable for DataDirectory {
    fn source_path(&self) -> &Path {
        &self.source_dir
    }

    fn destination_path(&self) -> &Path {
        &self.dest_dir
    }

    fn display_name(&self) -> &str {
        &self.name
    }
}

impl FindInDir for DataDirectory {
    fn new_from_path(path: PathBuf, state: &State) -> Result<Self, Error> {
        let name = path.file_name()
            .ok_or_else(|| format_err!("Entry at {} had no file name", path.display()))?
            .to_owned();

        Ok(DataDirectory {
            name: format!("data/{}", name.to_string_lossy()),
            dest_dir: state.xdg_data_home().join(&name),
            source_dir: path,
        })
    }
}

impl Installable for BinFile {
    fn source_path(&self) -> &Path {
        &self.source_path
    }

    fn destination_path(&self) -> &Path {
        &self.dest_path
    }

    fn display_name(&self) -> &str {
        &self.name
    }
}

impl FindInDir for BinFile {
    fn new_from_path(path: PathBuf, state: &State) -> Result<Self, Error> {
        let name = path.file_name()
            .ok_or_else(|| format_err!("Entry at {} had no file name", path.display()))?
            .to_owned();

        Ok(BinFile {
            name: format!("~/bin/{}", name.to_string_lossy()),
            dest_path: state.home().join("bin").join(&name),
            source_path: path,
        })
    }
}

impl Installable for CustomTarget {
    fn source_path(&self) -> &Path {
        &self.source_path
    }

    fn destination_path(&self) -> &Path {
        &self.dest_path
    }

    fn display_name(&self) -> &str {
        &self.name
    }

    fn after_install_action(&self) -> Option<Result<(), Error>> {
        if let Some(ref command) = self.shell_callback {
            use std::process;

            info!("Running shell command:\n  {}", command);
            Some(match process::Command::new("sh")
                .current_dir(self.destination_path().parent().unwrap())
                .arg("-c")
                .arg(&command)
                .status()
            {
                Ok(status) if status.success() => {
                    debug!("Command finished successfully");
                    Ok(())
                }
                Ok(status) => {
                    error!(
                        "Command failed with exit status {}",
                        status.code().unwrap_or(0)
                    );
                    // Don't abort the rest of the install because of this.
                    Ok(())
                }
                Err(error) => Err(error)
                    .context(format!("Could not run manifest callback {}", command))
                    .map_err(Error::from),
            })
        } else {
            None
        }
    }
}

impl CustomTarget {
    pub fn new<P>(
        source_path: P,
        destination_path: P,
        shell_callback: Option<String>,
    ) -> CustomTarget
    where
        P: Into<PathBuf>,
    {
        let destination_path = destination_path.into();
        let name = destination_path
            .file_name()
            .unwrap()
            .to_string_lossy()
            .into_owned();

        CustomTarget {
            name: name,
            source_path: source_path.into(),
            dest_path: destination_path,
            shell_callback: shell_callback,
        }
    }

    pub fn new_to_dir<P>(
        source_path: P,
        destination_parent: &Path,
        shell_callback: Option<String>,
    ) -> CustomTarget
    where
        P: Into<PathBuf>,
    {
        let source_path = source_path.into();
        let destination_path;
        let name;

        {
            let real_name = source_path.file_name().unwrap();
            destination_path = destination_parent.join(real_name);
            name = real_name.to_string_lossy().into_owned();
        }

        CustomTarget {
            name: name,
            source_path: source_path,
            dest_path: destination_path,
            shell_callback: shell_callback,
        }
    }
}
