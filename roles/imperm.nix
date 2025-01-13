{
  config,
  inputs,
  ...
}: let
  persistRoot = "/nix/persist"; # Anything important we want backed up
  secureRoot = "${persistRoot}/secure"; # Files and directories we want only root to access
  cacheRoot = "/nix/perist-cache"; # Anything not as important that we can stand losing
  preWith = pre: paths: builtins.map (p: "${pre}/${p}") paths;
  preShare = preWith ".local/share";
  preConf = preWith ".config";
in {
  imports = [inputs.imperm.nixosModules.default];
  # Requires /nix/persist and /nix/cache to exist

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
    directories =
      (preWith "/var" ([
          "log"
        ]
        ++ preWith "lib" (
          [
            "bluetooth"
            "nixos"
          ]
          ++ preWith "systemd" [
            "coredump"
            "timers"
            "backlight"
            "rfkill"
          ]
        )))
      ++ [
        {
          directory = "/var/lib/colord";
          user = "colord";
          group = "colord";
          mode = "u=rwx,g=rx,o=";
        }
      ];
    users.bean.directories =
      [
        ".cache"
        ".cargo"
        ".npm"
        ".pnpm"
        ".local/state/wireplumber"
      ]
      ++ (preShare ["Steam" "Trash" "dolphin"])
      ++ (preConf ["gh" "GitHub Desktop" "spotify" "vesktop" "kdeconnect" "keepassxc"]);
  };

  environment.persistence.${persistRoot} = {
    enable = true;
    hideMounts = true;
    directories = [
      "/var/lib/fprint"
      "/etc/NetworkManager/system-connections"
    ];
    users.bean = {
      directories =
        [
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
        ]
        ++ (preShare [
          "direnv"
          "ow-mod-man"
          "OuterWildsModManager"
          "PrismLauncher"
          "newsboat"
          "zoxide"
          "nvim"
        ]);
      files =
        (preConf [
          "nushell/history.txt"
        ])
        ++ (preShare [
          "user-places.xbel"
        ]);
    };
  };
}
