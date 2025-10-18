{ pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      fira-code
      fira-go
      nerd-fonts.symbols-only
      noto-fonts-color-emoji
      unifont
      liberation_ttf
    ];
    fontconfig = {
      enable = true;
      defaultFonts =
        let
          mainFonts = [
            "FiraGO"
            "Symbols Nerd Font"
          ];
        in
        {
          serif = mainFonts;
          sansSerif = mainFonts;
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
}
