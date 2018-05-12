mod all;
mod cleanup;
mod install;
mod post;
mod self_update;

pub use self::all::run as all;
pub use self::cleanup::run as cleanup;
pub use self::install::run as install;
pub use self::post::run as post;
pub use self::self_update::run as self_update;
