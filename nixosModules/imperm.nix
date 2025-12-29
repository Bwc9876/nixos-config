{...}: {
  config,
  lib,
  inputs,
  ...
}: {
  imports = [inputs.imperm.nixosModules.default];

  options.cow.imperm = {
    enable = lib.mkEnableOption "Impermanence, turns off mutable users and expects you to define their password hashes";
    persistRoot = lib.mkOption {
      type = lib.types.str;
      default = "/nix/persist";
      description = "Path to store persisted data";
    };
    cacheRoot = lib.mkOption {
      type = lib.types.str;
      default = "/nix/perist-cache";
      description = "Path to store cache data";
    };
    keep = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Paths to keep that should be backed up";
      default = [];
    };
    keepCache = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Paths to keep that shouldn't be backed up";
      default = [];
    };
  };

  config = let
    users =
      if config.cow.hm.enable
      then config.home-manager.users
      else {};
    persistRoot = config.cow.imperm.persistRoot; # Anything important we want backed up
    cacheRoot = config.cow.imperm.cacheRoot; # Anything not as important that we can stand losing
  in
    lib.mkIf config.cow.imperm.enable {
      users.mutableUsers = false;

      boot.lanzaboote.pkiBundle = lib.mkIf config.cow.lanzaboote.enable "${persistRoot}/secure/secureboot";

      services.openssh.hostKeys = lib.mkIf config.cow.ssh-server.enable [
        {
          bits = 4096;
          path = "${persistRoot}/secure/ssh_host_rsa_key";
          type = "rsa";
        }
        {
          path = "${persistRoot}/secure/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];

      environment.persistence = {
        "${cacheRoot}" = {
          enable = true;
          hideMounts = true;
          directories =
            [
              "/var/log"
              "/var/lib/nixos"
              "/var/lib/systemd/coredump"
              "/var/lib/systemd/timers"
              "/var/lib/systemd/rfkill"
              "/var/lib/systemd/backlight"
							"/var/tmp"
            ]
            ++ config.cow.imperm.keepCache;
          users =
            builtins.mapAttrs (_: v: {
              directories = v.cow.imperm.keepCache or [];
            })
            users;
        };
        "${persistRoot}" = {
          enable = true;
          hideMounts = true;
          directories = config.cow.imperm.keep;
          users =
            builtins.mapAttrs (_: v: {
              directories = v.cow.imperm.keep or [];
              files = v.cow.imperm.keepFiles or [];
            })
            users;
        };
      };
    };
}
