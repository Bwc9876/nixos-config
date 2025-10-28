{
  config,
  inputs,
  ...
}: let
  persistRoot = "/nix/persist"; # Anything important we want backed up
  secureRoot = "${persistRoot}/secure"; # Files and directories we want only root to access
  cacheRoot = "/nix/perist-cache"; # Anything not as important that we can stand losing
  preWith = pre: builtins.map (p: "${pre}/${p}");
  preShare = preWith ".local/share";
  preConf = preWith ".config";
in {
  imports = [inputs.imperm.nixosModules.default];

  environment.etc."machine-id".text = builtins.hashString "md5" config.networking.hostName;

  users.mutableUsers = false;
  users.users = {
    bean.hashedPasswordFile = "${secureRoot}/hashed-passwd";
    root.hashedPasswordFile = "${secureRoot}/hashed-passwd";
  };

  environment.persistence.${cacheRoot} = {
    enable = true;
    hideMounts = true;
    directories =
      (preWith "/var" (
        [
          "log"
        ]
        ++ preWith "lib" (
          [
            "bluetooth"
            "nixos"
            "libvirt"
            "iwd"
          ]
          ++ preWith "systemd" [
            "coredump"
            "timers"
            "backlight"
            "rfkill"
          ]
        )
      ))
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
      ++ (preShare [
        "Steam"
        "Trash"
      ])
      ++ (preConf [
        "kdeconnect"
        "keepassxc"
        "syncthing"
      ]);
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
          ".floorp"
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
        ++ (preConf [
          "Cemu"
        ])
        ++ (preShare [
          # "direnv"
          "ow-mod-man"
          "OuterWildsModManager"
          "PrismLauncher"
          "newsboat"
          "zoxide"
          "nvim"
          "Cemu"
          "mpd"
        ]);
      files = preConf [
        "nushell/history.txt"
      ];
    };
  };
}
