{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    jdk
  ];

  networking.firewall.allowedTCPPorts = [
    25565
  ];

  networking.firewall.allowedUDPPorts = [
    19132
  ];
}
