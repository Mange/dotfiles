use std::path::{Path, PathBuf};

use prelude::*;
use target::{FindInDir, Installable};

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
