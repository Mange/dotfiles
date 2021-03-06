use prelude::*;
use std::fs;
use std::process::Command;

/// Install/update myself
pub fn run(state: &State, _called_explicitly: bool) -> Result<(), Error> {
    compile_binary(state).and_then(|_| copy_binary_to_bin_collection(state))
}

fn compile_binary(state: &State) -> Result<(), Error> {
    let cli_dir = state.root().join("dotfiles-cli");

    debug!("Compiling dotfiles binary");
    match Command::new("cargo")
        .arg("build")
        .arg("--release")
        .current_dir(cli_dir)
        .status()
    {
        Ok(status) if status.success() => {
            debug!("Command finished successfully");
            Ok(())
        }
        Ok(status) => Err(format_err!(
            "Compiling dotfiles binary failed with exit status {}",
            status.code().unwrap_or(0)
        )),
        Err(error) => Err(error)
            .context("Compiling dotfiles binary failed")
            .map_err(Error::from),
    }
}

fn copy_binary_to_bin_collection(state: &State) -> Result<(), Error> {
    let binary_path = state
        .root()
        .join("dotfiles-cli")
        .join("target")
        .join("release")
        .join("dotfiles");
    let config_path = state.root().join("bin").join("dotfiles");

    // Replacing the existing binary is only possible if the file is unlinked (removed) first.
    if config_path.exists() {
        fs::remove_file(&config_path)?;
    }

    fs::copy(&binary_path, &config_path).map_err(|i| {
        format_err!(
            "Failed to copy {} to {}: {}",
            binary_path.display(),
            config_path.display(),
            i
        )
    })?;

    Ok(())
}
