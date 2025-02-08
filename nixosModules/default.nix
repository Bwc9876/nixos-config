{lib, ...}: let
  allNodesOf = nodeType: dir: lib.attrNames (lib.filterAttrs (_n: v: v == nodeType) dir);
  allRoles = builtins.readDir ./.;
  allNixFiles = dir:
    lib.pipe (builtins.readDir dir) [
      (allNodesOf "regular")
      (builtins.filter (s: s != "default.nix"))
      (builtins.filter (lib.hasSuffix ".nix"))
    ];

  # Flat Roles: roles that are normal .nix file in nixosModules/
  rolesFiles = builtins.map (lib.removeSuffix ".nix") (allNixFiles ./.);
  flatRoles = lib.genAttrs rolesFiles (p: ./. + "/${p}.nix");

  # Nested Roles: roles that are a folder containing a number of .nix files
  rolesDirs = allNodesOf "directory" allRoles;
  createNestedRole = dir: let
    nixFiles = allNixFiles (./. + "/${dir}");
  in {
    imports = builtins.map (f: ./. + "/${dir}" + "/${f}") nixFiles;
  };
  nestedRoles = lib.genAttrs rolesDirs createNestedRole;
in
  flatRoles // nestedRoles
