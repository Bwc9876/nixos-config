{...}: {
  pkgs,
  config,
  lib,
  ...
}: {
  options.cow.games.enable = lib.mkEnableOption "playing games with Steam";

  config = lib.mkIf config.cow.games.enable {
    home.packages = with pkgs; [
      # steam
      cemu
      owmods-cli
      owmods-gui
      prismlauncher
    ];

    cow.imperm.keepCache = [
      ".local/share/Steam"
      ".local/share/ow-mod-man"
      ".local/share/OuterWildsModManager"
      ".local/share/PrismLauncher"
      ".local/share/Cemu"
    ];
  };
}
