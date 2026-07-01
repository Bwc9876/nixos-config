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

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    lanzaboote.url = "github:nix-community/lanzaboote";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";

    wayland-mpris-idle-inhibit.url = "git+https://knot.bwc9876.dev/did:plc:3jyd4oaj5uywmu5b3ij3leym";
    wayland-mpris-idle-inhibit.inputs.nixpkgs.follows = "nixpkgs";

    fenix.url = "github:nix-community/fenix/monthly";
    fenix.inputs.nixpkgs.follows = "nixpkgs";

    catppuccin.url = "github:catppuccin/nix";
    catppuccin.inputs.nixpkgs.follows = "nixpkgs";

    # cat-stylus = {
    #   url = "https://github.com/catppuccin/userstyles/releases/download/all-userstyles-export/import.json";
    #   flake = false;
    # };

    nvf.url = "github:NotAShelf/nvf";
    nvf.inputs.nixpkgs.follows = "nixpkgs";

    impermanence.url = "github:nix-community/impermanence";
    impermanence.inputs.nixpkgs.follows = "nixpkgs";
    impermanence.inputs.home-manager.follows = "home-manager";

    nu_plugin_dbus.url = "git+https://knot.bwc9876.dev/did:plc:2oab3hjwitemxd3mycmqoz3t";
    nu_plugin_dbus.inputs.nixpkgs.follows = "nixpkgs";

    bingus.url = "git+https://knot.bwc9876.dev/did:plc:7gtakopu2pdi4knzuctkkraj";
    bingus.inputs.nixpkgs.follows = "nixpkgs";

    niri.url = "github:sodiboo/niri-flake";
    niri.inputs.nixpkgs.follows = "nixpkgs";

    tangled.url = "git+https://knot1.tangled.sh/did:plc:j5hmlfdrwkvtxm7cjmu7j2is";
    tangled.inputs.nixpkgs.follows = "nixpkgs";

    tranquil.url = "git+https://knot1.tangled.sh/did:plc:jj6ajj6duxnlthwtnob4qyuv";
    tranquil.inputs.nixpkgs.follows = "nixpkgs";

    spoon.url = "git+https://codeberg.org/spoonbaker/mono";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flakelight,
    flakelight-treefmt,
    nix-index-db,
    home-manager,
    nixos-hardware,
    lanzaboote,
    wayland-mpris-idle-inhibit,
    fenix,
    catppuccin,
    # cat-stylus,
    nvf,
    impermanence,
    nu_plugin_dbus,
    bingus,
    spoon,
    niri,
    tangled,
    tranquil,
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

      homeModule = {lib, ...}: {
        _module.args = {inherit inputs;};
        imports = let
          deps = [
            inputs.nix-index-db.homeModules.nix-index
            inputs.catppuccin.homeModules.catppuccin
            inputs.niri.homeModules.niri
            inputs.wayland-mpris-idle-inhibit.homeModules.default
            inputs.nvf.homeManagerModules.default
          ];
          myMods = lib.mapAttrsToList (k: v: ./homeModules/${k}) (builtins.readDir ./homeModules);
        in
          deps ++ myMods;
      };

      nixosModule = {lib, ...}: {
        _module.args = {inherit inputs;};
        imports = let
          deps = [
            inputs.home-manager.nixosModules.default
            inputs.catppuccin.nixosModules.catppuccin
            inputs.lanzaboote.nixosModules.lanzaboote
            inputs.impermanence.nixosModules.default
            inputs.tranquil.nixosModules.default
            inputs.tangled.nixosModules.knot
            inputs.tangled.nixosModules.spindle
          ];
          myMods = lib.mapAttrsToList (k: v: ./nixosModules/${k}) (builtins.readDir ./nixosModules);
        in
          deps ++ myMods;
      };

      nixDir = ./.;
      legacyPackages = pkgs: pkgs;
      nixpkgs.config = {
        allowUnfree = true;
      };
    };
}
