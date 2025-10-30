{...}: {
  config,
  lib,
  pkgs,
  ...
}: let
  pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKsVzdJra+x5aEuwTjL1FBOiMh9bftvs8QwsM1xyEbdd";
in {
  options.cow.bean = {
    enable = lib.mkEnableOption "Bean user";
    sudoer = lib.mkEnableOption "Bean being a sudoer";
  };

  config = {
    users.users.bean = lib.mkIf config.cow.bean.enable {
      isNormalUser = true;
      description = "Ben C";
      extraGroups = lib.optional config.cow.bean.sudoer "wheel";
      shell = pkgs.nushell;
      openssh.authorizedKeys.keys = pubkey;
    };

    home-manager.users.bean = {
      cow.bean = {
        enable = config.cow.bean.enable;
        inherit pubkey;
      };
      cow.games.enable = config.cow.bean.enable && config.cow.gaming.enable;
      cow.gdi = lib.mkIf config.cow.bean.enable {
        inherit (config.cow.gdi) enable doIdle;
        useUWSM = true;
      };
    };
  };
}
