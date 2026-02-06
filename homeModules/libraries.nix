{...}: {
  config,
  lib,
  ...
}: {
  options.cow.libraries.enable = lib.mkEnableOption "Setting common library directories";

  config = lib.mkIf config.cow.libraries.enable {
    xdg = {
      enable = true;
      userDirs = let
        inherit (config.home) homeDirectory;
      in {
        enable = true;
        desktop = "${homeDirectory}/Desktop";
        documents = "${homeDirectory}/Documents";
        pictures = "${homeDirectory}/Pictures";
        videos = "${homeDirectory}/Videos";
        music = "${homeDirectory}/Music";
        extraConfig = {
          "SCREENSHOTS" = "${homeDirectory}/Pictures/Screenshots";
        };
      };
    };
  };
}
