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
  };

  outputs = inputs @ {
    self,
    nixpkgs,
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
  }: let
    lib = (import ./lib.nix) nixpkgs.lib;
    pkgsFor = system:
      import nixpkgs {
        inherit system;
      };
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
      sys = value.eval {
        inherit inputs;
      };
    in
      mkSystem (sys
        // {
          target = value.target;
          inherit name;
        })) (lib.parseAllFiles ./systems);
  };
}
