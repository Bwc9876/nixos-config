# NixOS Config

This repo contains the flake I use to configure any of my NixOS-configured devices.

## Structure

- flake.nix: Central file for exporting all my configs and anything else I need.
- lib.nix: Helper functions
- systems/: All systems this flake configures, each system has some options that describe it but the main thing that determines what options they set are _roles_.
- roles/: A role is a feature a system can have (ex. the `graphics` role enables Hyprland, GUI apps, etc). Roles can either be a singular nix file, or a folder of them if they're complicated. Files named `role1+role2.nix` represent an _overlap_ role, which is applied if all roles delimited by `+` are turned on.
- base/: This folder contains modules applied unconditionally to all systems.
- res/: Non-nix files used in the config. Pictures, scripts, etc.
- pkgs/: Custom nix packages made for my config.
- create-sys/: WIP tool for automating the creation of new systems. Currently just has an interactive prompt for adding a new `.nix` file to `systems/`.

## Implementation

I'm not going to lie, I have no idea what I'm doing. Is every feature here implmemented well? Definitely not, but that's okay!
