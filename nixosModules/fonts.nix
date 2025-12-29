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
        # fira-go
        noto-fonts
        noto-fonts-lgc-plus
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        nerd-fonts.symbols-only
        noto-fonts-color-emoji
        corefonts
        unifont
        liberation_ttf
      ];
      fontconfig = {
        enable = true;
        defaultFonts = {
          serif = [
            "Noto Serif"
            "Symbols Nerd Font"
          ];
          sansSerif = [
            "FiraGO"
            "Symbols Nerd Font"
          ];
          monospace = [
            "Fira Code"
            "Symbols Nerd Font"
          ];
          emoji = [
            "Noto Color Emoji"
            "Symbols Nerd Font"
          ];
        };
      };
    };
  };
}
