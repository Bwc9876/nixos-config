{
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [inputs.lanzaboote.nixosModules.lanzaboote];

  boot = {
    loader.systemd-boot.enable = lib.mkForce false;
    bootspec.enable = true;

    lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };
  };
}
