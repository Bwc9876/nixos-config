{ config, lib, ... }:
{
  options.cow.network = {
    wireless = lib.mkEnableOption "wireless networking with IWD";
    bluetooth = lib.mkEnableOption "bluetooth networking";
  };

  config = {
    hardware.bluetooth = lib.mkIf config.cow.network.bluetooth {
      enable = true;
      settings = {
        General = {
          Experimental = true;
        };
      };
    };

    cow.imperm.keepCache =
      (lib.optional config.cow.network.bluetooth [
        "/var/lib/bluetooh"
      ])
      ++ (lib.optional config.cow.network.wireless [ "/var/lib/iwd" ]);

    networking = lib.mkIf config.cow.network.wireless {
      iwd.enable = true;
      useNetworkd = true;
      useDHCP = true;
    };

    systemd.network = {
      enable = lib.mkDefault config.cow.network.wireless;
      wait-online = {
        enable = lib.mkDefault false;
      };
    };

    services = lib.mkIf config.cow.network.wireless {
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
