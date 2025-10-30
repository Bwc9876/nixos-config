{outputs, ...}: {
  lib,
  inputs,
  config,
  ...
}: {
  imports = [inputs.hm.nixosModules.default];
  options.cow.hm.enable = lib.mkEnableOption "Home Manager";

  config.home-manager = lib.mkIf config.cow.hm.enable {
    sharedModules = builtins.attrValues outputs.homeModules;
    useUserPackages = true;
  };
}
