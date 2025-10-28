{ config, lib, ... }:
{
  options.cow.pfp = {
    enable = lib.mkEnableOption "Enable setting profile picture";
    file = lib.mkOption {
      type = lib.types.string;
      description = "Path to Profile Picture File (PNG, 1:1 Aspect)";
    };
  };

  config = lib.mkIf config.cow.pfp.enable {
    home.file.".face".source = config.cow.pfp.file;
  };
}
