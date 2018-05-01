use prelude::*;

/// Delete broken symlinks from `$HOME`, etc.
pub fn run(state: &State, called_explicitly: bool) -> Result<(), Error> {
    use std::fs;

    debug!("Cleaning up $HOME…");
    let mut cleaned = 0;

    for entry in state.home().read_dir()? {
        let entry = entry?;
        let path = entry.path();
        let metadata = path.symlink_metadata()?;
        if metadata.file_type().is_symlink() && !path.exists() {
            let dest = path.read_link()?;
            warn!(
                "Deleting broken symlink {} ({})",
                path.display(),
                dest.display()
            );
            fs::remove_file(path)?;
            cleaned += 1;
        }
    }

    if cleaned > 0 {
        info!("Cleaned {} file(s)", cleaned);
    } else if called_explicitly {
        info!("Nothing to clean up :)");
    }
    Ok(())
}
