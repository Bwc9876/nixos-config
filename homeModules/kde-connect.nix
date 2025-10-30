{...}: {
  config,
  lib,
  ...
}: {
  options.cow.kde-connect.enable = lib.mkEnableOption "KDE connect to connect to phones";

  config = lib.mkIf config.cow.kde-connect.enable {
    cow.imperm.keepCache = [".config/kdeconnect"];
    cow.firewall.tcp = lib.range 1714 1764;
    systemd.user.services.kdeconnect.Service.Environment = lib.mkForce [];
  };
}
