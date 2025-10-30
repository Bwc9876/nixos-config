{...}: {
  inputs,
  lib,
  config,
  ...
}: {
  imports = [inputs.lanzaboote.nixosModules.lanzaboote];

  options.cow.lanzaboote.enable = lib.mkEnableOption "Use lanzaboote for booting and secure boot";

  config.boot = lib.mkIf config.cow.lanzaboote.enable {
    loader.systemd-boot.enable = lib.mkForce false;
    bootspec.enable = true;

    lanzaboote = {
      enable = true;
      pkiBundle = lib.mkDefault (
        if config.cow.imperm.enable
        then "/nix/persist/secure/secureboot"
        else "/etc/secureboot"
      );
    };
  };
}
