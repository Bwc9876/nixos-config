{...}: {
  pkgs,
  config,
  lib,
  ...
}: {
  options.cow.fonts.enable =
    (lib.mkEnableOption "font management")
    // {
      default = config.cow.gdi.enable;
    };

  config = lib.mkIf config.cow.fonts.enable {
    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
        fira-code
        maple-mono.NF-CN
        noto-fonts
      ];
      fontconfig = {
        enable = true;
        defaultFonts = {
          serif = [
            "Noto Serif"
          ];
          sansSerif = [
            "FiraGO"
          ];
          monospace = [
            "Maple Mono NF CN"
          ];
          emoji = [
            "Noto Color Emoji"
          ];
        };
      };
    };
  };
}
