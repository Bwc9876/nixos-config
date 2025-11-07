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

          services.kmscon = {
            enable = true;
            autologinUser = "root";
            fonts = [
              {
                name = "SauceCodePro Nerd Font Mono";
                package = pkgs.nerd-fonts.sauce-code-pro;
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

          system.extraDependencies = [
            outputs.nixosConfigurations.aperture.config.system.build.toplevel
            outputs.nixosConfigurations.black-mesa.config.system.build.toplevel
          ];

          environment.systemPackages = with pkgs; [
            disko
            sbctl
          ];
        }
      )
      (
        {pkgs, ...}: {
          system.stateVersion = "25.05";
          networking.hostName = "cow-installer";

          networking.networkmanager.enable = lib.mkForce false;

          isoImage.squashfsCompression = "xz -Xdict-size 100%";

          users.users.root = {
            shell = pkgs.nushell;
          };

          home-manager.users.root.home.stateVersion = "25.05";
          home-manager.users.root.cow = {
            nushell = {
              enable = true;
              commandNotFound = true;
            };
            neovim.enable = true;
            htop.enable = true;
            starship.enable = true;
            yazi.enable = true;
            dev.enable = false;
            comma.enable = true;
            cat.enable = true;
          };

          cow = {
            network = {
              enable = true;
              wireless = true;
            };
            hm.enable = true;
            cat.enable = true;
          };
        }
      )
    ];
}
