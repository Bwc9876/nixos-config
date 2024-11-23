{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-index-db.url = "github:Mic92/nix-index-database";
    nix-index-db.inputs.nixpkgs.follows = "nixpkgs";
    hm.url = "github:nix-community/home-manager";
    hm.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    lanzaboote.url = "github:nix-community/lanzaboote";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    ow-mod-man.url = "github:ow-mods/ow-mod-man";
    ow-mod-man.inputs.nixpkgs.follows = "nixpkgs";
    gh-grader-preview.url = "github:Bwc9876/gh-grader-preview";
    gh-grader-preview.inputs.nixpkgs.follows = "nixpkgs";
    wayland-mpris-idle-inhibit.url = "github:Bwc9876/wayland-mpris-idle-inhibit";
    wayland-mpris-idle-inhibit.inputs.nixpkgs.follows = "nixpkgs";
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nix-index-db,
    hm,
    nixos-hardware,
    lanzaboote,
    ow-mod-man,
    gh-grader-preview,
    wayland-mpris-idle-inhibit,
    rust-overlay,
  }: let
    lib = (import ./lib.nix) nixpkgs.lib;
    pkgsForWithOverlays = system: overlays:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays =
          [
            ow-mod-man.overlays.default
            rust-overlay.overlays.default
            nix-index-db.overlays.nix-index
          ]
          ++ overlays;
      };
    pkgsFor = system: pkgsForWithOverlays system [];
    baseMods = builtins.map (name: "${self}/base/${name}") (builtins.attrNames (builtins.readDir ./base));
    availableRoles = lib.getRoles ./roles;
    mkSystem = lib.mkmkSystem {
      inherit baseMods availableRoles;
      specialArgs = {
        inherit inputs;
      };
    };
  in {
    inherit lib;
    legacyPackages = lib.forAllSystems pkgsFor;
    formatter = lib.forAllSystems (system: (pkgsFor system).alejandra);
    nixosConfigurations = builtins.mapAttrs (name: value: let
      pkgs = pkgsForWithOverlays value.target value.extraOverlays;
      sys = value.eval {
        inherit inputs pkgs;
      };
    in
      mkSystem (sys
        // {
          target = value.target;
          inherit name pkgs;
        })) (lib.parseAllFiles ./systems);
  };
}
