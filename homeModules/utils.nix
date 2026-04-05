{
  config,
  lib,
  pkgs,
  ...
}: {
  options.cow.utils = {
    enable =
      (lib.mkEnableOption "Handy utilities to have")
      // {
        default = true;
      };
    batAliases =
      (lib.mkEnableOption "Aliases for bat commands in the shell")
      // {
        default = true;
      };
  };

  config = lib.mkIf config.cow.utils.enable {
    cow = {
      btop.enable = true;
      ddhx.enable = true;
    };

    home.packages = with pkgs;
      [
        ripgrep
        binutils
        usbutils
        file
        procfd
        dust
        zip
        unzip
        libqalculate
        p7zip
        file
        screen
        util-linux
        inetutils
        just
        man-pages
        dig
        tealdeer

        hyfetch
        fastfetch
      ]
      ++ lib.optionals config.cow.gdi.enable [
        wev
      ];

    home.shellAliases = lib.mkIf config.cow.utils.batAliases {
      cat = "bat";
      man = "batman";
      bg = "batgrep";
      bdiff = "batdiff";
    };

    programs.bat = {
      enable = true;
      syntaxes = {
        nushell.src = ../res/bat-nushell.sublime-syntax.yaml;
      };
      extraPackages = with pkgs.bat-extras; [
        batdiff
        batman
        batgrep
        batwatch
      ];
    };

    programs.hyfetch = {
      enable = true;
      settings = {
        backend = "fastfetch";
        color_align = {
          custom_colors = [];
          fore_back = null;
          mode = "horizontal";
        };
        distro = null;
        light_dark = "dark";
        lightness = 0.5;
        mode = "rgb";
        preset = "gay-men";
        pride_month_disable = false;
        pride_month_shown = [];
      };
    };
  };
}
