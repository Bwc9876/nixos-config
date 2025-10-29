{
  config,
  lib,
  ...
}: {
  options.cow.libraries.enable = lib.mkEnableOption "Creating common library directories";

  config = lib.mkIf config.cow.libraries.enable {
    xdg = {
      enable = true;
      userDirs = let
        inherit (config.home) homeDirectory;
      in {
        enable = true;
        createDirectories = true;
        desktop = "${homeDirectory}/Desktop";
        documents = "${homeDirectory}/Documents";
        pictures = "${homeDirectory}/Pictures";
        videos = "${homeDirectory}/Videos";
        music = "${homeDirectory}/Music";
        extraConfig = {
          "XDG_SCREENSHOTS_DIR" = "${homeDirectory}/Pictures/Screenshots";
        };
      };
    };
  };
}
