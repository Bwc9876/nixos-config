{...}: {
  config,
  lib,
  ...
}: {
  options.cow.role-desktop = {
    enable = lib.mkEnableOption "configuring a desktop computer with GUI";
  };

  config = lib.mkIf config.cow.role-desktop.enable {
    security.sudo.wheelNeedsPassword = false;

    cow = {
      bean.enable = true;
      firewall.openForUsers = true;
      hm.enable = true;
      network = {
        enable = true;
        bluetooth = lib.mkDefault true;
        wireless = lib.mkDefault true;
      };
      cat.enable = true;
      gdi = {
        enable = true;
        doIdle = lib.mkDefault false;
        showGreet = true;
      };
      audio.enable = true;
    };
  };
}
