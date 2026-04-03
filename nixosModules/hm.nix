{
  lib,
  config,
  inputs,
  ...
}: {
  options.cow.hm.enable = lib.mkEnableOption "Home Manager";

  config.home-manager = lib.mkIf config.cow.hm.enable {
    sharedModules = [inputs.self.homeModules.default];
    useUserPackages = true;
    useGlobalPkgs = false;
  };
}
