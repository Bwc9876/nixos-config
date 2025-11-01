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

    cow.imperm.keep = [".config/keepassxc"];

    wayland.windowManager.hyprland.settings.exec-once =
      lib.optionals (config.cow.gdi.enable && config.cow.keepassxc.dbPath != null)
      (
        let
          cmd = "keepassxc ${config.cow.keepassxc.dbPath}";
        in [
          (
            if config.cow.gdi.useUWSM
            then "uwsm app -- ${cmd}"
            else cmd
          )
        ]
      );
    home.packages = with pkgs; [keepassxc];
  };
}
