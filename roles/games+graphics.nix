{
  pkgs,
  inputs,
  ...
}: {
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    prismlauncher
    ace-of-penguins
    # inputs.ow-mod-man.packages.${system}.owmods-gui
    libsForQt5.kmousetool
  ];
}
