{...}: {
  config,
  lib,
  ...
}: {
  options.cow.sync.enable = lib.mkEnableOption "syncing via SyncThing";

  config = lib.mkIf config.cow.sync.enable {
    cow.imperm.keepCache = [".config/syncthing"];

    cow.firewall = {
      tcp = [22000];
      udp = [21027 22000];
    };

    services.syncthing = {
      enable = true;

      overrideFolders = false;
      overrideDevices = false;

      settings.options.urAccepted = -1;
    };
  };
}
