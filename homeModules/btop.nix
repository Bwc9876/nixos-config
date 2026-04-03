{...}: {
  config,
  lib,
  pkgs,
  ...
}: {
  options.cow.btop.enable = lib.mkEnableOption "btop + customizations";

  config = lib.mkIf config.cow.btop.enable {
    programs.btop = {
      enable = true;
      settings = {
        proc_sorting = "memory";
        proc_left = true;
        show_uptime = false;
        clock_format = "%I:%M:%S %P | /user@/host for /uptime";
      };
    };
  };
}
