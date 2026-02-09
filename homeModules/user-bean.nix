{...}: {
  pkgs,
  lib,
  config,
  ...
}: {
  options.cow.bean = {
    enable = lib.mkEnableOption "Bean user presets";
    username = lib.mkOption {
      type = lib.types.str;
      description = "username";
      default = "bean";
    };
    name = lib.mkOption {
      type = lib.types.str;
      description = "Friendly name of user";
      default = "Ben C";
    };
    pubkey = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "Public key to accept for bean";
      default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKsVzdJra+x5aEuwTjL1FBOiMh9bftvs8QwsM1xyEbdd";
    };
    email = lib.mkOption {
      type = lib.types.str;
      # TODO: Tangled supports DIDs instead...
      description = "Email to use for Git operations";
      default = lib.join "@bwc9876" [
        "ben"
        ".dev"
      ];
    };
  };

  config = let
    conf = config.cow.bean;
  in
    lib.mkIf conf.enable {
      # My Personal config using most of my HM modules

      home = {
        file.".ssh/authorized_keys".text = lib.mkIf (conf.pubkey != null) ''
          ${conf.pubkey} ${conf.username}
        '';
        username = lib.mkDefault conf.username;
        homeDirectory = lib.mkDefault "/home/${conf.username}";
      };

      programs.jujutsu.settings = {
        user = {
          inherit (conf) name email;
        };
        git = {
          sign-on-push = true;
        };
        signing = {
          behavior = "drop";
          backend = "ssh";
          key = lib.mkIf (conf.pubkey != null) conf.pubkey;
        };
      };

      programs.git = {
        signing = lib.mkIf (conf.pubkey != null) {
          format = "ssh";
          signByDefault = true;
        };
        settings = {
          user = {
            inherit (conf) name email;
            signingKey = lib.mkIf (conf.pubkey != null) conf.pubkey;
          };
        };
      };

      home.packages = lib.mkIf config.cow.gdi.enable (
        with pkgs; [
          zoom-us
          tuxpaint
        ]
      );

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
        jj.enable = true;
        comma.enable = true;
        cat.enable = true;

        keepassxc = {
          enable = true;
          dbPath = lib.mkDefault "${config.xdg.userDirs.documents}/Keepass/DB/Database.kdbx";
        };
      };
    };
}
