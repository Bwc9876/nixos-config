{
  description = "A very basic flake for a basic cow";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flakelight = {
      url = "github:nix-community/flakelight";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flakelight-treefmt = {
      url = "github:m15a/flakelight-treefmt";
      inputs.flakelight.follows = "flakelight";
    };

    crane.url = "github:ipetkov/crane";

    nix-index-db = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    wayland-mpris-idle-inhibit = {
      url = "git+https://knot.bwc9876.dev/did:plc:3jyd4oaj5uywmu5b3ij3leym";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flakelight.follows = "flakelight";
        crane.follows = "crane";
      };
    };

    fenix = {
      url = "github:nix-community/fenix/monthly";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:NotAShelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    nu_plugin_dbus = {
      url = "git+https://knot.bwc9876.dev/did:plc:2oab3hjwitemxd3mycmqoz3t";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        crane.follows = "crane";
        flakelight.follows = "flakelight";
      };
    };

    bingus = {
      url = "git+https://knot.bwc9876.dev/did:plc:7gtakopu2pdi4knzuctkkraj";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        fenix.follows = "fenix";
        crane.follows = "crane";
        flakelight.follows = "flakelight";
        flakelight-treefmt.follows = "flakelight-treefmt";
      };
    };

    tangled = {
      url = "git+https://knot1.tangled.sh/did:plc:j5hmlfdrwkvtxm7cjmu7j2is";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        fenix.follows = "fenix";
      };
    };

    spoon.url = "git+https://knot.bwc9876.dev/did:plc:m64qpmj33xm6r3sf5s44nevd";
  };

  outputs = inputs @ {
    flakelight,
    flakelight-treefmt,
    ...
  }:
    flakelight ./. {
      inherit inputs;
      imports = [
        flakelight-treefmt.flakelightModules.default
        ./flakelightModules/repl.nix
      ];

      treefmtConfig = {
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
            inputs.wayland-mpris-idle-inhibit.homeModules.default
            inputs.nvf.homeManagerModules.default
          ];
          myMods = lib.mapAttrsToList (k: _v: ./homeModules/${k}) (builtins.readDir ./homeModules);
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
            inputs.tangled.nixosModules.knot-rs
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
