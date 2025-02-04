lib: rec {
  parseAllFiles = folder:
    lib.mapAttrs' (fileName: _: let
      parsed = import (folder + "/${fileName}");
    in {
      name = builtins.head (lib.splitString "." fileName);
      value = parsed;
    })
    (builtins.readDir
      folder);
  getRoles = folder:
    lib.mapAttrs' (
      nodeName: nodeType: let
        c =
          if nodeType == "regular"
          then builtins.map (x: x) [(folder + "/${nodeName}")]
          else builtins.map (name: (folder + "/${nodeName}/${name}")) (builtins.attrNames (builtins.readDir "${folder}/${nodeName}"));
      in {
        name = builtins.head (lib.splitString "." nodeName);
        value = c;
      }
    ) (builtins.readDir folder);
  forAllSystems = lib.genAttrs lib.systems.flakeExposed;
  roleActive = role: selected: builtins.all (r: builtins.elem r selected) (lib.splitString "+" role);
  filterRoles = availableRoles: roles:
    lib.attrsets.filterAttrs (
      name: _: roleActive name roles
    )
    availableRoles;
  mkmkSystem = {
    baseMods,
    specialArgs,
    availableRoles,
  }: {
    name,
    description,
    target,
    edition,
    roles,
    extraModules,
    includeBaseMods,
  }:
    lib.nixosSystem {
      specialArgs = {inherit edition target;} // specialArgs;

      modules =
        [
          specialArgs.inputs.hm.nixosModules.default
          specialArgs.inputs.nix-index-db.nixosModules.nix-index
          {
            nixpkgs = {
              system = target;
              config.allowUnfree = true;
            };

            networking.hostName = name;
            environment.variables."HOSTNAME" = name;
            environment.etc."flake-src".source = specialArgs.inputs.self;
            home-manager.extraSpecialArgs = specialArgs;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            system.stateVersion = edition;
          }
        ]
        ++ (
          if includeBaseMods
          then baseMods
          else []
        )
        ++ lib.flatten (builtins.attrValues (
          filterRoles availableRoles roles
        ))
        ++ extraModules;
    };
}
