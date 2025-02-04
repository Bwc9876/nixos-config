{
  target = "x86_64-linux";

  eval = {...}: {
    description = "Installer ISO";
    edition = "25.05";

    includeBaseMods = true;

    roles = ["latest-linux" "black-mesa-cache"];
    extraModules = [
      ({
        pkgs,
        lib,
        inputs,
        edition,
        config,
        modulesPath,
        ...
      }: {
        imports = [
          "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
        ];

        services.kmscon = {
          enable = true;
          autologinUser = "bean";
          fonts = [
            {
              name = "FiraMono Nerd Font Mono";
              package = pkgs.nerd-fonts.fira-mono;
            }
          ];
        };

        boot = rec {
          initrd.systemd.enable = false;
          supportedFilesystems = {
            btrfs = true;
            reiserfs = true;
            vfat = true;
            f2fs = true;
            xfs = true;
            ntfs = true;
            cifs = true;
            zfs = lib.mkForce false;
          };
          initrd.supportedFilesystems = supportedFilesystems;
        };

        environment.systemPackages = with pkgs; [
          gptfdisk
        ];
      })
    ];
  };
}
