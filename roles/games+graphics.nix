{
  pkgs,
  inputs,
  ...
}: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    prismlauncher
    # inputs.ow-mod-man.packages.${system}.owmods-gui
    libsForQt5.kmousetool
  ];
}
