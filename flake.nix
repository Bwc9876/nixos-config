{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flakelight.url = "github:nix-community/flakelight";
    flakelight.inputs.nixpkgs.follows = "nixpkgs";
    nix-index-db.url = "github:Mic92/nix-index-database";
    nix-index-db.inputs.nixpkgs.follows = "nixpkgs";
    hm.url = "github:nix-community/home-manager";
    hm.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    lanzaboote.url = "github:nix-community/lanzaboote";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    gh-grader-preview.url = "github:Bwc9876/gh-grader-preview";
    gh-grader-preview.inputs.nixpkgs.follows = "nixpkgs";
    wayland-mpris-idle-inhibit.url = "github:Bwc9876/wayland-mpris-idle-inhibit";
    wayland-mpris-idle-inhibit.inputs.nixpkgs.follows = "nixpkgs";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    catppuccin.url = "github:catppuccin/nix";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.inputs.home-manager.follows = "hm";
    imperm.url = "github:nix-community/impermanence";
    nu_plugin_dbus.url = "github:Bwc9876/nu_plugin_dbus";
    nu_plugin_dbus.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flakelight,
    nix-index-db,
    hm,
    nixos-hardware,
    lanzaboote,
    gh-grader-preview,
    wayland-mpris-idle-inhibit,
    rust-overlay,
    catppuccin,
    nixvim,
    imperm,
    nu_plugin_dbus,
  }:
    flakelight ./. {
      inherit inputs;
      formatters = pkgs: {
        "*.nix" = "alejandra .";
        "*.sh" = "shfmt -w .";
      };
      packages =
        nixpkgs.lib.genAttrs ["gh-grader-preview" "wayland-mpris-idle-inhibit" "nu_plugin_dbus"]
        (i: {pkgs}: let input = builtins.getAttr i inputs; in input.packages.${pkgs.system}.default);
      nixDir = ./.;
      nixDirAliases = {
        nixosConfigurations = ["systemConfigs"];
      };
      legacyPackages = pkgs: pkgs;
      nixpkgs.config = {
        allowUnfree = true;
      };
    };
}
