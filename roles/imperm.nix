{config, ...}: {
  # Requires /nix/persist to exist
  # TODO: Bind mount game save directories

  environment.etc."machine-id".text = builtins.hashString "md5" config.networking.hostName;

  environment.persistence."/nix/persist" = {
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
      "/etc/NetworkManager/system-connections"
      "/etc/passwd"
      "/etc/shadow"
      "/etc/secureboot"
      {
        directory = "/var/lib/colord";
        user = "colord";
        group = "colord";
        mode = "u=rwx,g=rx,o=";
      }
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
        {
          directory = ".local/share/Steam";
          method = "symlink";
        }
        ".local/share/zoxide"
      ];
      files = [
        ".config/nushell/history.txt"
      ];
    };
  };
}
