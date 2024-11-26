use std::{
    fs,
    path::Path,
    process::{Command, Stdio},
};

use inquire::{validator::Validation, Confirm, Editor, MultiSelect, Select, Text};

use crate::prelude::*;

fn list_roles(roles_folder: &Path) -> Result<Vec<String>> {
    Ok(fs::read_dir(roles_folder)
        .context("Failed to read roles")?
        .into_iter()
        .filter_map(|r| {
            r.ok()
                .map(|d| d.file_name().to_string_lossy().trim_end_matches(".nix").to_string())
                .filter(|n| !n.contains('+'))
        })
        .collect())
}

const NO_HARDWARE_MOD: &str = "No NixOS Hardware Module";

fn list_hardware_modules() -> Result<Vec<String>> {
    let mut cmd = Command::new("nix");
    cmd.arg("eval")
        .arg("github:nixos/nixos-hardware#nixosModules")
        .arg("--raw")
        .arg("--apply")
        .arg("s: builtins.toJSON (builtins.attrNames s)")
        .stdout(Stdio::piped())
        .stderr(Stdio::null());

    let output = cmd.output().context("Failed to fetch systems")?.stdout;
    let mut modules: Vec<String> = serde_json::from_slice(&output).context("Failed to parse systems")?;

    modules.insert(0, NO_HARDWARE_MOD.into());

    Ok(modules)
}

fn list_targets() -> Result<Vec<String>> {
    let mut cmd = Command::new("nix");
    cmd.arg("eval")
        .arg("nixpkgs#lib.systems.flakeExposed")
        .arg("--raw")
        .arg("--apply")
        .arg("builtins.toJSON")
        .stdout(Stdio::piped())
        .stderr(Stdio::null());

    let output = cmd.output().context("Failed to fetch systems")?.stdout;
    let modules = serde_json::from_slice(&output).context("Failed to parse systems")?;
    Ok(modules)
}

fn get_nixpkgs_version() -> Result<String> {
    let mut cmd = Command::new("nix");
    cmd.arg("eval")
        .arg("nixpkgs#lib.version")
        .arg("--raw")
        .stdout(Stdio::piped())
        .stderr(Stdio::null());


    let output = cmd.output().context("Failed to fetch systems")?.stdout;
    let output = String::from_utf8_lossy(&output);

    let otp = output.trim().split('.').take(2).collect::<Vec<_>>();

    Ok(otp.join("."))
}


fn gen_hardware_config(root: Option<&Path>) -> Result<String> {
    let mut cmd = Command::new("nixos-generate-config");
    cmd.arg("--show-hardware-config").stdout(Stdio::piped());

    if let Some(root) = root {
        cmd.arg("--root").arg(root);
    }

    let output = cmd.output().context("Failed to fetch systems")?.stdout;
    let output = String::from_utf8_lossy(&output);

    let otp = output.trim().split('\n').skip(3).collect::<Vec<_>>();
    Ok(format!("({})", otp.join("\n")))
}

struct System {
    name: String,
    description: String,
    edition: String,
    target: String,
    include_base_mods: bool,
    roles: Vec<String>,
    hardware_config: String,
    hardware_mod: String,
}

fn dialog(flake_root: &Path) -> Result<System> {
    // Name

    let fl_root_val = flake_root.to_owned();

    let system_filter = move |name: &str| {
        Ok(if !name.is_empty() && name.chars().all(|c| c.is_ascii_lowercase() || c.is_ascii_digit() || c == '-') {
            if fl_root_val.join("systems").join(format!("{name}.nix")).is_file() {
                Validation::Invalid("System config already exists!".into())
            } else {
                Validation::Valid
            }
        } else {
            Validation::Invalid("System configs should use kebab-case".into())
        })
    };

    let system_name = Text::new("Enter a name for the new system")
        .with_validator(system_filter)
        .prompt()
        .context("Failed to get system name")?;

    // Target

    let targets = list_targets().context("Failed to get targets")?;
    let system_target = Select::new("Select what arch/OS this system will target", targets)
        .prompt()
        .context("Failed to prompt for system target")?;

    // Description

    let description = Text::new("Enter system description")
        .prompt_skippable()
        .context("Failed to prompt for description")?
        .unwrap_or_else(|| "Generic".to_string());

    // Base Mods

    let include_base_mods = Confirm::new("Should this system include base modules?")
        .with_default(true)
        .prompt()
        .context("Failed to prompt")?;

    // Generate Hardware Config?

    let gen_hw_config = Confirm::new("Would you like to auto-generate a hardware configuration for this system with `nixos-generate-config`?").prompt().context("Failed to prompt")?;
    let hw_config = if gen_hw_config {
        gen_hardware_config(None).context("Failed to generate hw config")?
    } else {
        String::new()
    };

    // NixOS Hardware

    let hardware_mod = if let Ok(modules) = list_hardware_modules() {
        let hardware_mod = Select::new("(Optional) Select a NixOS Hardware Module for the System", modules).with_starting_cursor(0).prompt().context("Failed to prompt for hw modules")?;
        if hardware_mod == NO_HARDWARE_MOD {
            String::new()
        } else {
            hardware_mod
        }
    } else {
        println!("Failed to fetch modules from NixOS hardware, continuing...");
        String::new()
    };

    // Asking For System Roles

    let roles_path = flake_root.join("roles");
    let roles = list_roles(&roles_path).context("Failed to list roles")?;
    let selected_roles = MultiSelect::new("Select the roles for this new system", roles)
        .prompt()
        .context("Failed to promp user for roles")?;

    Ok(System {
        name: system_name,
        description: description,
        target: system_target,
        roles: selected_roles.into_iter().map(|r| format!("\"{r}\"")).collect(),
        edition: get_nixpkgs_version().context("Failed to get latest")?,
        include_base_mods,
        hardware_config: hw_config,
        hardware_mod,
    })
}

impl System {

    const FILE_TEMPLATE: &str = include_str!("sys_template.nix");

    fn generate_file(&self) -> String {
        Self::FILE_TEMPLATE
            .replace("__TARGET__", &self.target)
            .replace("__DESCRIPTION__", &self.description)
            .replace("__EDITION__", &self.edition)
            .replace("__INCL_BASE_MODS__", &self.include_base_mods.to_string())
            .replace("__ROLES__", &self.roles.join(" "))
            .replace("__HARDWARE_MOD__", &self.hardware_mod)
            .replace("__HARDWARE_CONFIG__", &self.hardware_config)
    }

}

pub fn add_system_dialog(flake_root: &Path) -> Result {
    let sys = dialog(flake_root)?;

    let file = sys.generate_file();

    let edited_file = Editor::new("Review the new system file with (e), confirm with (enter)").with_predefined_text(&file).with_file_extension(".nix").prompt().context("Failed to get edits")?;

    let path = flake_root.join("systems").join(format!("{}.nix", sys.name));

    println!("Saving New File to {}", path.display());

    fs::write(path, &edited_file).context("Failed to write new file")
}
