{pkgs, ...}: {
  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };

  networking.wireless.iwd.enable = true;
  environment.systemPackages = with pkgs; [iw];

  networking.useNetworkd = true;
  networking.useDHCP = true;

  systemd.network = {
    enable = true;
    wait-online = {
      anyInterface = true;
      enable = false;
    };
  };
  services.resolved = {
    enable = true;
    llmnr = "false";
    fallbackDns = [
      "2606:4700:4700::1111"
      "2606:4700:4700::1001"
      "1.1.1.1"
      "1.0.0.1"
    ];
  };
  services.timesyncd.servers = map (x: "time-${x}-g.nist.gov") [
    "a"
    "b"
    "c"
    "d"
    "e"
    "f"
    "g"
  ];
}
