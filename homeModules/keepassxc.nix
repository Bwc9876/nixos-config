{...}: {
  config,
  lib,
  pkgs,
  ...
}: {
  options.cow.keepassxc = {
    enable = lib.mkEnableOption "KeePassXC + autolaunch";
    dbPath = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "KeePassXC DB to open on DE launch if cow.gdi is on";
      default = null;
    };
  };

  config = lib.mkIf config.cow.keepassxc.enable {
    cow.imperm.keepCache = [".config/keepassxc"];

    programs.niri.settings.spawn-at-startup =
      lib.optionals (config.cow.gdi.enable && config.cow.keepassxc.dbPath != null)
      [
        {
          argv = [
            "keepassxc"
            config.cow.keepassxc.dbPath
          ];
        }
      ];
    home.packages = with pkgs; [keepassxc];
  };
}
