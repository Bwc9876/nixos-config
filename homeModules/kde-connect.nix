{...}: {
  config,
  lib,
  ...
}: {
  options.cow.kde-connect = {
    enable = lib.mkEnableOption "KDE connect to connect to phones";
    dev-name = lib.mkOption {
      type = lib.types.str;
      description = "Name of the device in KDE connect";
    };
  };

  config = lib.mkIf config.cow.kde-connect.enable {
    cow.imperm.keepCache = [".config/kdeconnect"];
    cow.firewall = let
      r = lib.range 1714 1764;
    in {
      tcp = r;
      udp = r;
    };
    xdg.configFile."kdeconnect/config".text = ''
      [General]
      name=${config.cow.kde-connect.dev-name}
    '';
    services.kdeconnect.enable = true;
    systemd.user.services.kdeconnect.Service.Environment = lib.mkForce [];
  };
}
