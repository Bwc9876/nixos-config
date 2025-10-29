{
  config,
  lib,
  ...
}: let
  listOfDirs = desc:
    lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = desc;
    };
in {
  options.cow.imperm = {
    keepLibraries = lib.mkEnableOption "persisting library (Documents, Pictures, etc.) directories";
    keepCache = listOfDirs "List of directories to persist if impermanence is enabled. These directories are *not* meant to be backed up";
    keep = listOfDirs "List of directories to persist if impermanence is enabled. These directories should be backed up";
    keepFiles = {
      type = lib.types.listOf lib.types.str;
      description = "List of files to keep. These files should be backed up";
    };
  };

  config = lib.mkIf config.cow.imperm.keepLibraries {
    cow.imperm.keep = [
      "Downloads"
      "Music"
      "Videos"
      "Pictures"
      "Documents"
      ".ssh"
      ".cache"
      ".local/state/wireplumber"
    ];
  };
}
