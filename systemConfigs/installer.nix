{outputs, ...}: {
  system = "x86_64-linux";
  modules = [
    (outputs.lib.applyRoles ["base" "latest-linux" "black-mesa-cache"])
    ({
      pkgs,
      lib,
      inputs,
      edition,
      config,
      modulesPath,
      ...
    }: {
      system.stateVersion = "25.05";
      networking.hostName = "nixos-installer-bwc9876";

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
}
