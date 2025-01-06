{
  config,
  inputs,
  ...
}: let
  persistRoot = "/nix/persist"; # Anything important we want backed up
  secureRoot = "${persistRoot}/secure"; # Files and directories we want only root to access
  cacheRoot = "/nix/cache"; # Anything not as important that we can stand losing
in {
  imports = [inputs.imperm.nixosModules.default];
  # Requires /nix/persist to exist
  # TODO: Bind mount game save directories

  environment.etc."machine-id".text = builtins.hashString "md5" config.networking.hostName;

  users.mutableUsers = false;
  users.users = {
    bean.hashedPasswordFile = "${secureRoot}/hashed-passwd";
    root.hashedPasswordFile = "${secureRoot}/hashed-passwd";
  };

  fileSystems."/tmp/nix-build" = {
    device = "${cacheRoot}/nix-build";
    options = ["bind" "X-fstrim.notrim" "x-gvfs-hide"];
  };

  systemd.services.nix-daemon = {
    environment.TMPDIR = "/tmp/nix-build";
    unitConfig.RequiresMountsFor = ["/tmp/nix-build" "/nix/store"];
  };

  environment.persistence.${cacheRoot} = {
    enable = true;
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/lib/systemd/timers"
      "/var/lib/systemd/backlight"
      "/var/lib/systemd/rfkill"
      {
        directory = "/var/lib/colord";
        user = "colord";
        group = "colord";
        mode = "u=rwx,g=rx,o=";
      }
    ];
    users.bean.directories = [
      ".cache"
      ".local/share/Steam" # Most saves are cloud backed up or in .local/share and I don't want to back up games themselves
      ""
    ];
  };

  environment.persistence.${persistRoot} = {
    enable = true;
    hideMounts = true;
    directories = [
      "/etc/NetworkManager/system-connections"
    ];
    files = [
      {
        file = "/var/keys/secret_file";
        parentDirectory = {mode = "u=rwx,g=,o=";};
      }
    ];
    users.bean = {
      directories = [
        "Downloads"
        "Music"
        "Videos"
        "Pictures"
        "Documents"
        ".mozilla"
        {
          directory = ".gnupg";
          mode = "0700";
        }
        {
          directory = ".ssh";
          mode = "0700";
        }
        {
          directory = ".nixops";
          mode = "0700";
        }
        {
          directory = ".local/share/keyrings";
          mode = "0700";
        }
        ".local/share/direnv"
        ".local/share/ow-mod-man"
        ".local/share/OuterWildsModManager"
        ".local/share/PrismLauncher"
        ".local/share/newsboat"
        ".local/share/zoxide"
        ".local/share/nvim"
        ".local/share/user-places.xbel"
        ".config/vesktop"
      ];
      files = [
        ".config/nushell/history.txt"
      ];
    };
  };
}
