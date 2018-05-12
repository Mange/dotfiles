use prelude::*;

/// Runs post.sh file if it exists.
pub fn run(state: &State, called_explicitly: bool) -> Result<(), Error> {
    use std::process;
    let post_file = state.root().join("post.sh");

    if post_file.exists() {
        debug!("Running {}", post_file.display());
        match process::Command::new(post_file)
            .current_dir(state.root())
            .status()
        {
            Ok(status) if status.success() => {
                debug!("Command finished successfully");
                Ok(())
            }
            Ok(status) => Err(format_err!(
                "Command failed with exit status {}",
                status.code().unwrap_or(0)
            )),
            Err(error) => Err(error)
                .context("post.sh script failed")
                .map_err(Error::from),
        }
    } else {
        let message = format!(
            "Cannot find post.sh file ({} does not exist)",
            post_file.display()
        );
        if called_explicitly {
            Err(format_err!("{}", message))
        } else {
            warn!("{}", message);
            Ok(())
        }
    }
}
