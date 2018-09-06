use std::path::{Path, PathBuf};

use prelude::*;
use target::{Target, TargetBuilder};

pub fn config_directories(dir: &Path, state: &State) -> Result<Vec<Target>, Error> {
    targets_in_dir(dir, state, new_config_directory)
}

pub fn data_directories(dir: &Path, state: &State) -> Result<Vec<Target>, Error> {
    targets_in_dir(dir, state, new_data_directory)
}

pub fn bin_files(dir: &Path, state: &State) -> Result<Vec<Target>, Error> {
    targets_in_dir(dir, state, new_bin_file)
}

fn targets_in_dir<F>(dir: &Path, state: &State, f: F) -> Result<Vec<Target>, Error>
where
    F: Fn(PathBuf, &State) -> Result<Target, Error>,
{
    dir.read_dir()?
        .map(|entry| f(entry?.path(), state))
        .collect()
}

fn new_config_directory(path: PathBuf, state: &State) -> Result<Target, Error> {
    let name = path
        .file_name()
        .ok_or_else(|| format_err!("Entry at {} had no file name", path.display()))?
        .to_owned();

    Ok(TargetBuilder::default()
        .source_path(path)
        .dest_path(state.xdg_config_home().join(&name))
        .name(format!("config/{}", name.to_string_lossy()))
        .build()
        .unwrap())
}

fn new_data_directory(path: PathBuf, state: &State) -> Result<Target, Error> {
    let name = path
        .file_name()
        .ok_or_else(|| format_err!("Entry at {} had no file name", path.display()))?
        .to_owned();

    Ok(TargetBuilder::default()
        .source_path(path)
        .dest_path(state.xdg_data_home().join(&name))
        .name(format!("data/{}", name.to_string_lossy()))
        .build()
        .unwrap())
}

fn new_bin_file(path: PathBuf, state: &State) -> Result<Target, Error> {
    let name = path
        .file_name()
        .ok_or_else(|| format_err!("Entry at {} had no file name", path.display()))?
        .to_owned();

    Ok(TargetBuilder::default()
        .source_path(path)
        .dest_path(state.home().join(".local").join("bin").join(&name))
        .name(format!("~/.local/bin/{}", name.to_string_lossy()))
        .build()
        .unwrap())
}
