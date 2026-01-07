{
  lib,
  outputs,
  ...
}: {
  system = "x86_64-linux";

  modules =
    (builtins.attrValues outputs.nixosModules)
    ++ [
      (
        {
          modulesPath,
          pkgs,
          ...
        }: {
          imports = [
            "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
          ];

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

          programs.wireshark.enable = true;

          services.cage = {
            enable = true;
            program = lib.getExe pkgs.wireshark;
            user = "root";
          };

          services.udisks2 = {
            enable = true;
            mountOnMedia = true;
          };
          services.devmon.enable = true;
        }
      )
      (
        {pkgs, ...}: {
          system.stateVersion = "25.05";
          networking.networkmanager.enable = lib.mkForce false;
          isoImage.squashfsCompression = "xz -Xdict-size 100%";
          programs.ssh.startAgent = false;
          cow = {
            base = {
              enable = true;
              env = false;
              util = false;
              tmp = false;
              nix = false;
              sysrqs = true;
            };
            network = {
              enable = true;
              wireless = true;
            };
          };
        }
      )
    ];
}
