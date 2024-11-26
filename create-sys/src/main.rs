use clap::clap_derive::Parser;

mod add;

mod prelude {
    use anyhow::Error as AError;
    use std::result::Result as SResult;

    pub type Result<T = (), E = AError> = SResult<T, E>;
    pub use anyhow::Context;
}

use prelude::*;

#[derive(Parser)]
struct Cli {}

fn main() -> Result {
    let dir = std::env::current_dir()?;
    let dir = dir.parent().context("")?;
    add::add_system_dialog(dir)
}
