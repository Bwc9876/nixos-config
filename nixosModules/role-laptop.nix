{ config, lib, ... }:
{
  options.cow.role-laptop = {
    enable = lib.mkEnableOption "configuring a laptop with a GUI and bean setup for mobile use";
    fingerPrintSensor = lib.mkEnableOption "fprintd and persist prints";
  };

  config = lib.mkIf config.cow.role-laptop.enable {
    cow = {
      user-bean.enable = true;
      firewall.openforUsers = true;
      print.enable = true;
      hm.enable = true;
      network = {
        bluetooth = true;
        wireless = true;
      };
      cat.enable = true;
      gdi.enable = true;
      imperm = lib.mkIf config.cow.role-laptop.fingerPrintSensor {
        keep = [ "/var/lib/fprintd" ];
      };
    };

    services.fprintd = lib.mkIf config.cow.role-laptop.fingerPrintSensor {
      enable = true;
    };
  };
}
