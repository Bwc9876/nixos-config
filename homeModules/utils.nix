{...}: {
  config,
  lib,
  pkgs,
  ...
}: {
  options.cow.utils.enable =
    (lib.mkEnableOption "Handy utilities to have")
    // {
      default = true;
    };

  config = lib.mkIf config.cow.utils.enable {
    home.packages = with pkgs;
      [
        binutils
        usbutils
        qrencode
        nmap
        file
        procfd
        dust
        zip
        inputs.gh-grader-preview.packages.${pkgs.system}.default
        wol
        libqalculate
        p7zip
        poop

        hyfetch
        fastfetch
      ]
      ++ lib.optional config.cow.gdi.enable wev;

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
        lightness = 0.65;
        mode = "rgb";
        preset = "interprogress";
        pride_month_disable = false;
        pride_month_shown = [];
      };
    };
  };
}
