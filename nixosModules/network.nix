{...}: {
  config,
  lib,
  pkgs,
  ...
}: {
  options.cow.network = {
    enable = lib.mkEnableOption "custom network setup using some nicer defaults";
    wireless = lib.mkEnableOption "wireless networking with IWD";
    bluetooth = lib.mkEnableOption "bluetooth networking";
  };

  config = lib.mkIf config.cow.network.enable {
    hardware.bluetooth = lib.mkIf config.cow.network.bluetooth {
      enable = true;
      settings = {
        General = {
          Experimental = true;
        };
      };
    };

    environment.systemPackages = with pkgs;
      (lib.optionals config.cow.network.bluetooth [
        bluetui
      ])
      ++ (lib.optionals config.cow.network.wireless [impala]);

    cow.imperm.keepCache =
      (lib.optional config.cow.network.bluetooth "/var/lib/bluetooth")
      ++ (lib.optional config.cow.network.wireless "/var/lib/iwd");

    networking = {
      wireless.iwd.enable = config.cow.network.wireless;
      useNetworkd = true;
      useDHCP = true;
    };

    systemd.network = {
      enable = lib.mkDefault true;
      wait-online = {
        enable = lib.mkDefault false;
      };
    };

    services = lib.mkDefault {
      resolved = {
        enable = true;
        llmnr = "false";
        fallbackDns = [
          "2606:4700:4700::1111"
          "2606:4700:4700::1001"
          "1.1.1.1"
          "1.0.0.1"
        ];
      };
      timesyncd.servers = map (x: "time-${x}-g.nist.gov") [
        "a"
        "b"
        "c"
        "d"
        "e"
        "f"
        "g"
      ];
    };
  };
}
