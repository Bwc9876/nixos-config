{outputs, ...}: {
  system = "x86_64-linux";
  modules = [
    (outputs.lib.applyRoles [
      "base"
      "latest-linux"
      "dev"
      "networking"
      "fun"
    ])
    (
      {
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
        networking.networkmanager.enable = lib.mkForce false;

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

        boot = let
          supportedFilesystems = {
            btrfs = true;
            reiserfs = lib.mkForce false;
            vfat = true;
            f2fs = true;
            xfs = true;
            ntfs = true;
            cifs = true;
            zfs = lib.mkForce false;
          };
        in {
          initrd.systemd.enable = false;
          inherit supportedFilesystems;
          initrd = {
            inherit supportedFilesystems;
          };
        };

        environment.systemPackages = with pkgs; [
          gptfdisk
        ];
      }
    )
  ];
}
