use prelude::*;

/// Run all the subcommands.
pub fn run(state: &State) -> Result<(), Error> {
    super::cleanup(state, false)
        .and_then(|_| super::install(state, false))
        .and_then(|_| super::post(state, false))
}
