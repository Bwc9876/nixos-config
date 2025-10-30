{...}: {
  config,
  lib,
  ...
}: {
  options.cow.pictures = {
    enable = lib.mkEnableOption "Enable setting profile picture";
    pfp = lib.mkOption {
      type = lib.types.path;
      description = "Path to Profile Picture File (PNG, 1:1 Aspect)";
    };
    bg = lib.mkOption {
      type = lib.types.path;
      description = "Path to the background image to use";
    };
  };

  config = lib.mkIf config.cow.pictures.enable {
    home.file.".face".source = config.cow.pictures.pfp;
  };
}
