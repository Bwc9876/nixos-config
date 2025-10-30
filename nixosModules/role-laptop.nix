{...}: {
  config,
  lib,
  ...
}: {
  options.cow.role-laptop = {
    enable = lib.mkEnableOption "configuring a laptop with a GUI and bean setup for mobile use";
    fingerPrintSensor = lib.mkEnableOption "fprintd and persist prints";
  };

  config = lib.mkIf config.cow.role-laptop.enable {
    home-manager.users.bean.cow = {
      music.enable = true;
      news.enable = true;
      qmplay2.enable = true;
      sync.enable = true;
      kde-connect.enable = true;
      dev.enable = true;
    };

    cow = {
      bean.enable = true;
      firewall.openForUsers = true;
      print.enable = true;
      hm.enable = true;
      network = {
        bluetooth = true;
        wireless = true;
      };
      cat.enable = true;
      gdi = {
        enable = true;
        showGreet = true;
      };
      audio.enable = true;
      imperm.keep = lib.optional config.cow.role-laptop.fingerPrintSensor "/var/lib/fprintd";
    };

    services.fprintd = lib.mkIf config.cow.role-laptop.fingerPrintSensor {
      enable = true;
    };
  };
}
