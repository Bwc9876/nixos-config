{ config, lib, ... }:
let
  listOfDirs =
    desc:
    lib.mkOption {
      type = lib.types.listOF lib.types.str;
    };
in
{
  options.cow.imperm = {
    keepLibraries = lib.mkEnableOption "persisting library (Documents, Pictures, etc.) directories";
    keepCache = listOfDirs "List of directories to persist if impermanence is enabled. These directories are *not* meant to be backed up";
    keep = listOfDirs "List of directories to persist if impermanence is enabled. These directories should be backed up";
  };

  config = config.cow.imperm.keepLibraries {
    cow.imperm.keep = [
      "Downloads"
      "Music"
      "Videos"
      "Pictures"
      "Documents"
    ];
  };
}
