{
  config,
  lib,
  ...
}: {
  options.cow.kde-connect.enable = "KDE connect to connect to phones";

  config = lib.mkIf config.cow.kde-connect.enable {
    cow.keepCache = [".config/kdeconnect"];
    cow.firewall.tcp = lib.range 1714 1764;
    systemd.services.kdeconnect.Service.Environment = lib.mkForce [];
  };
}
