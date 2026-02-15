{
  description = "A very basic flake for a basic cow";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flakelight.url = "github:nix-community/flakelight";
    flakelight.inputs.nixpkgs.follows = "nixpkgs";
    flakelight-treefmt.url = "github:m15a/flakelight-treefmt";
    flakelight-treefmt.inputs.flakelight.follows = "flakelight";
    nix-index-db.url = "github:nix-community/nix-index-database";
    nix-index-db.inputs.nixpkgs.follows = "nixpkgs";
    hm.url = "github:nix-community/home-manager";
    hm.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    lanzaboote.url = "github:nix-community/lanzaboote";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    wayland-mpris-idle-inhibit.url = "github:Bwc9876/wayland-mpris-idle-inhibit";
    wayland-mpris-idle-inhibit.inputs.nixpkgs.follows = "nixpkgs";
    fenix.url = "github:nix-community/fenix/monthly";
    fenix.inputs.nixpkgs.follows = "nixpkgs";
    catppuccin.url = "github:catppuccin/nix";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";
    # cat-stylus = {
    #   url = "https://github.com/catppuccin/userstyles/releases/download/all-userstyles-export/import.json";
    #   flake = false;
    # };
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
    imperm.url = "github:nix-community/impermanence";
    imperm.inputs.nixpkgs.follows = "nixpkgs";
    imperm.inputs.home-manager.follows = "hm";
    nu_plugin_dbus.url = "github:Bwc9876/nu_plugin_dbus";
    nu_plugin_dbus.inputs.nixpkgs.follows = "nixpkgs";
    gh-grader-preview.url = "github:Bwc9876/gh-grader-preview";
    gh-grader-preview.inputs.nixpkgs.follows = "nixpkgs";
    bingus.url = "github:Bwc9876/bingus-bot";
    bingus.inputs.nixpkgs.follows = "nixpkgs";
    niri.url = "github:sodiboo/niri-flake";
    niri.inputs.nixpkgs.follows = "nixpkgs";
    musnix.url = "github:musnix/musnix";
    musnix.inputs.nixpkgs.follows = "nixpkgs";
    tangled.url = "git+https://tangled.org/tangled.org/core";
    tangled.inputs.nixpkgs.follows = "nixpkgs";

    spoon.url = "git+https://codeberg.org/spoonbaker/mono";
    spoon.inputs = {
      nixpkgs.follows = "nixpkgs";
      flakelight.follows = "flakelight";
      home-manager.follows = "hm";
      impermanence.follows = "imperm";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flakelight,
    flakelight-treefmt,
    nix-index-db,
    hm,
    nixos-hardware,
    lanzaboote,
    wayland-mpris-idle-inhibit,
    fenix,
    catppuccin,
    # cat-stylus,
    nixvim,
    imperm,
    nu_plugin_dbus,
    bingus,
    spoon,
    gh-grader-preview,
    niri,
    musnix,
    tangled,
  }:
    flakelight ./. {
      inherit inputs;
      imports = [
        flakelight-treefmt.flakelightModules.default
        spoon.flakelightModules.repl
        spoon.flakelightModules.ubercheck
      ];

      treefmtConfig = {pkgs, ...}: {
        programs = {
          alejandra.enable = true;
          just.enable = true;
          shfmt.enable = true;
        };
      };

      nixDir = ./.;
      legacyPackages = pkgs: pkgs;
      nixpkgs.config = {
        allowUnfree = true;
      };
    };
}
