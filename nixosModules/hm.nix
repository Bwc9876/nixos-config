{lib, inputs, ...}: {
  imports = [inputs.hm.nixosModules.default];
  options.cow.hm.enable = lib.mkEnableOption "Home Manager";
}
