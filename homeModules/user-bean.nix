{...}: {
  pkgs,
  lib,
  config,
  ...
}: {
  options.cow.bean = {
    enable = lib.mkEnableOption "Bean user presets";
    pubkey = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "Public key to accept for bean";
      default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKsVzdJra+x5aEuwTjL1FBOiMh9bftvs8QwsM1xyEbdd";
    };
  };

  config = lib.mkIf config.cow.bean.enable {
    # My Personal config using most of my HM modules

    home = {
      file.".ssh/authorized_keys".text = lib.mkIf (config.cow.bean.pubkey != null) ''
        ${config.cow.bean.pubkey} bean
      '';
      username = lib.mkDefault "bean";
      homeDirectory = lib.mkDefault "/home/bean";
    };

    programs.git = {
      signing = lib.mkIf (config.cow.bean.pubkey != null) {
        format = "ssh";
        signByDefault = true;
      };
      settings = {
        user = {
          email = "bwc9876@gmail.com";
          name = "Ben C";
          signingKey = lib.mkIf (config.cow.bean.pubkey != null) config.cow.bean.pubkey;
        };
      };
    };

    home.packages = with pkgs; [
      libreoffice-qt6
      obs-studio
      loupe
      inkscape
      lorien
      zoom-us
      tuxpaint
    ];

    home.sessionVariables = {
      "EDITOR" = "nvim";
    };

    xdg.mimeApps.defaultApplications = lib.mkIf config.cow.gdi.enable {
      "image/svg+xml" = "org.inkscape.Inkscape.desktop";
      "image/*" = "org.gnome.Loupe.desktop";
    };

    cow = {
      libraries.enable = true;
      imperm.keepLibraries = true;
      pictures = {
        enable = true;
        pfp = ../res/pictures/cow.png;
        bg = ../res/pictures/background.png;
      };
      nushell = {
        enable = true;
        commandNotFound = true;
      };
      neovim.enable = true;
      htop.enable = true;
      starship.enable = true;
      dev.enable = true;
      comma.enable = true;
      cat.enable = true;

      keepassxc = {
        enable = true;
        dbPath = lib.mkDefault "${config.xdg.userDirs.documents}/Keepass/DB/Database.kdbx";
      };
    };
  };
}
