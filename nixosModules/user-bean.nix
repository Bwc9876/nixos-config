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
    pubkey = lib.mkOption {
      type = lib.types.str;
      description = "Public Key to Add for Bean";
      default = pubkey;
    };
  };

  config = lib.mkIf config.cow.bean.enable {
    users.users.bean = {
      isNormalUser = true;
      description = "Ben C";
      extraGroups = lib.optionals config.cow.bean.sudoer ["wheel"];
      shell = pkgs.nushell;
      openssh.authorizedKeys.keys = [config.cow.bean.pubkey];
    };

    home-manager.users.bean = lib.mkIf config.cow.hm.enable {
      cow.bean = {
        inherit (config.cow.bean) enable;
        inherit (config.cow.bean) pubkey;
      };
      cow.games.enable = config.cow.gaming.enable;
      cow.gdi = {
        inherit (config.cow.gdi) enable doIdle;
      };
    };
  };
}
