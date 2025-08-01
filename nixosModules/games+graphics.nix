{pkgs, ...}: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    extest.enable = true;
  };

  programs.gamescope.enable = true;

  environment.systemPackages = with pkgs; [
    # prismlauncher - Disabled until openjdk doesn't have a cycle
    owmods-gui
    owmods-cli
    cemu
  ];
}
