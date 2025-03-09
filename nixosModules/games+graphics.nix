{pkgs, ...}: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  programs.gamescope.enable = true;

  environment.systemPackages = with pkgs; [
    prismlauncher
    owmods-gui
    owmods-cli
  ];
}
