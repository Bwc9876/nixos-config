{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.cow.gaming.enable = lib.mkEnableOption "Gaming stuff";

  config = lib.mkIf config.cow.gaming.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      extest.enable = true;
    };

    programs.gamescope.enable = true;

    environment.systemPackages = with pkgs; [
      prismlauncher
      owmods-gui
      owmods-cli
      cemu
    ];
  };
}
