{
  lib,
  config,
  ...
}:
let
  pubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKsVzdJra+x5aEuwTjL1FBOiMh9bftvs8QwsM1xyEbdd";
in
{

  options.cow.bean.enable = lib.mkEnableOption "Bean user presets";

  config = lib.mkIf config.cow.bean.enable {
    # My Personal config using most of my HM modules

    home = {
      file.".ssh/authorized_keys".text = ''
        ${pubkey} bean
      '';
      username = lib.mkDefault "bean";
      homeDirectory = lib.mkDefault "/home/bean";
    };

    programs.git.config.user = {
      email = "bwc9876@gmail.com";
      name = "Ben C";
      signingKey = pubkey;
    };

    cow = {
      libraries.enable = true;
      imperm = {
        enable = true;
        keepLibraries = true;
      };
      pictures = {
        pfp = ../res/pictures/cow.png;
        bg = ../res/pictures/background.png;
      };
      nushell = {
        enable = true;
        commandNotFound = true;
      };
      nvim.enable = true;
      htop.enable = true;
      starship.enable = true;
      yazi.enable = true;
      dev.enable = true;
      comma.enable = true;
      cat.enable = true;

      firefox = config.cow.gdi.enable;
      waybar = config.cow.gdi.enable;
      keepassxc.dbPath = lib.mkDefault "${config.xdg.userDirs.documents}/KeePass/DB";
    };
  };
}
