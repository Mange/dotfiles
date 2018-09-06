use prelude::*;
use std::fs;
use std::path::Path;

/// Delete broken symlinks from installation directories, etc.
pub fn run(state: &State, called_explicitly: bool) -> Result<(), Error> {
    let mut cleaned = 0;

    cleaned += clean_up_symlinks(state.home());
    cleaned += clean_up_symlinks(state.xdg_config_home());
    cleaned += clean_up_symlinks(state.xdg_data_home());
    cleaned += clean_up_symlinks(&state.home().join(".local").join("bin"));

    if cleaned > 0 {
        info!("Cleaned {} file(s)", cleaned);
    } else if called_explicitly {
        info!("Nothing to clean up :)");
    }
    Ok(())
}

fn clean_up_symlinks(directory: &Path) -> i32 {
    debug!("Cleaning up {}…", directory.display());
    match delete_broken_symlinks(directory) {
        Ok(cleaned) => cleaned,
        Err(error) => {
            error!(
                "Failed to clean up symlinks in {}: {}",
                directory.display(),
                error
            );
            0
        }
    }
}

fn delete_broken_symlinks(directory: &Path) -> Result<i32, Error> {
    let mut cleaned = 0;

    for entry in directory.read_dir()? {
        let entry = entry?;
        let path = entry.path();
        if is_broken_symlink(&path).unwrap_or(false) {
            match delete_symlink(&path) {
                Ok(_) => cleaned += 1,
                Err(error) => error!("Could not delete symlink: {}", error),
            }
        }
    }

    Ok(cleaned)
}

fn delete_symlink(path: &Path) -> Result<(), Error> {
    let dest = path.read_link()?;
    warn!(
        "Deleting broken symlink {} ({})",
        path.display(),
        dest.display()
    );
    fs::remove_file(path)?;

    Ok(())
}

fn is_broken_symlink(path: &Path) -> Result<bool, Error> {
    let metadata = path.symlink_metadata()?;
    Ok(metadata.file_type().is_symlink() && !path.exists())
}
