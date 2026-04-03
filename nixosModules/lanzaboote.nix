{
  lib,
  config,
  ...
}: {
  options.cow.lanzaboote.enable = lib.mkEnableOption "Use lanzaboote for booting and secure boot";

  config.boot = lib.mkIf config.cow.lanzaboote.enable {
    loader.systemd-boot.enable = lib.mkForce false;
    bootspec.enable = true;

    lanzaboote = {
      enable = true;
      pkiBundle = lib.mkDefault "/var/lib/sbctl";
    };
  };
}
