{...}: {
  config,
  lib,
  ...
}: {
  options.cow.role-laptop = {
    enable = lib.mkEnableOption "configuring a laptop with a GUI and bean setup for mobile use";
    fingerPrintSensor = lib.mkEnableOption "fprintd and persist prints";
    powersave =
      (lib.mkEnableOption "power saving and battery health options with TLP")
      // {
        default = true;
      };
  };

  config = lib.mkIf config.cow.role-laptop.enable {
    home-manager.users.bean.cow = lib.mkIf config.cow.bean.enable {
      music.enable = true;
      news.enable = true;
      qmplay2.enable = true;
      sync.enable = true;
      dev.enable = true;
    };

    cow = {
      base.enable = true;
      bean.enable = true;
      firewall.openForUsers = true;
      print.enable = true;
      hm.enable = true;
      network = {
        enable = true;
        bluetooth = true;
        wireless = true;
      };
      cat.enable = true;
      gdi = {
        enable = true;
        doIdle = true;
        showGreet = true;
      };
      audio.enable = true;
      imperm.keep = lib.optional config.cow.role-laptop.fingerPrintSensor "/var/lib/fprint";
    };

    # Set to null as TLP will manage the frequency governor for us
    powerManagement.cpuFreqGovernor = lib.mkIf config.cow.role-laptop.powersave (
      if config.cow.audio.tweaks.enable
      then (lib.mkForce null)
      else null
    );

    services.tlp = lib.mkIf config.cow.role-laptop.powersave {
      enable = true;
      pd.enable = true;
    };

    services.fprintd = lib.mkIf config.cow.role-laptop.fingerPrintSensor {
      enable = true;
    };
  };
}
