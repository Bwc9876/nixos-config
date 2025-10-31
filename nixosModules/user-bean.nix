{ ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKsVzdJra+x5aEuwTjL1FBOiMh9bftvs8QwsM1xyEbdd";
in
{
  options.cow.bean = {
    enable = lib.mkEnableOption "Bean user";
    sudoer = lib.mkEnableOption "Bean being a sudoer";
  };

  config = lib.mkIf config.cow.bean.enable {
    users.users.bean = {
      isNormalUser = true;
      description = "Ben C";
      extraGroups = lib.optional config.cow.bean.sudoer "wheel";
      shell = pkgs.nushell;
      openssh.authorizedKeys.keys = [ pubkey ];
    };

    home-manager.users.bean = {
      cow.bean = {
        inherit (config.cow.bean) enable;
        inherit pubkey;
      };
      cow.games.enable = config.cow.gaming.enable;
      cow.gdi = {
        inherit (config.cow.gdi) enable doIdle;
        useUWSM = true;
      };
    };
  };
}
