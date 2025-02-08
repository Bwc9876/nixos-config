{
  outputs,
  lib,
  ...
}: let
  roleEnabled = selected: role: builtins.all (r: builtins.elem r selected) (lib.splitString "+" role);
in {
  applyRoles = roleList: let
    filteredRoles = lib.filterAttrs (n: _v: roleEnabled roleList n) outputs.nixosModules;
  in {
    imports = builtins.attrValues filteredRoles;
  };
}
