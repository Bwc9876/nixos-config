{
  inputs,
  outputs,
  ...
}: {
  system = "x86_64-linux";
  specialArgs.inputs = inputs // inputs.spoon.inputs // {inherit (inputs) self;};

  modules =
    (builtins.attrValues outputs.nixosModules)
    ++ [
      inputs.nixos-hardware.nixosModules.common-gpu-amd
      inputs.nixos-hardware.nixosModules.common-cpu-amd
      inputs.spoon.nixosModules.black-mesa
      {
        home-manager.users.bean.home.stateVersion = "25.05";
        system.stateVersion = "25.05";
        networking.hostName = "black-mesa";

        powerManagement.cpuFreqGovernor = "performance";

        boot.initrd.availableKernelModules = [
          "nvme"
          "xhci_pci"
          "ahci"
          "usbhid"
          "usb_storage"
          "sd_mod"
        ];
        boot.kernelModules = ["kvm-amd"];
        boot.extraModulePackages = [];

        hardware.enableRedistributableFirmware = true;

        # Other disks handled by cow.disks
        fileSystems."/mnt/storage" = {
          device = "/dev/sda1";
          fsType = "btrfs";
        };

        users.users = let
          secureRoot = "/nix/persist/secure";
        in {
          bean.hashedPasswordFile = "${secureRoot}/hashed-passwd";
          root.hashedPasswordFile = "${secureRoot}/hashed-passwd";
        };

        home-manager.users.bean.cow = {
          sync.enable = true;
          dev.enable = true;
        };

        cow = {
          bean.sudoer = true;
          lanzaboote.enable = true;
          ssh-server.enable = true;
          role-desktop.enable = true;
          gaming.enable = true;
          imperm.enable = true;
          disks = {
            enable = true;
            partition-prefix = "cow-bm";
            swap = false;
            luks = true;
          };
        };
      }
      {
        # Bingus!
        imports = [inputs.bingus.nixosModules.default];
        nixpkgs.overlays = [inputs.bingus.overlays.default];

        cow.imperm.keep = [
          "/var/lib/private/bingus"
        ];

        services.bingus-bot = {
          enable = true;
          tokenFile = "/nix/persist/secure/bingus-token";
          replyChannels = [
            1295447496948191262
            1295245646542143489
          ];
        };
      }
      {
        # for WOL
        systemd.network.links."79-eth-wol" = {
          matchConfig = {
            Type = "ether";
            Driver = "!veth";
            Virtualization = "false";
          };
          linkConfig = {
            WakeOnLan = "magic";
            NamePolicy = "keep kernel database onboard slot path";
            AlternativeNamesPolicy = "database onboard slot path mac";
            MACAddressPolicy = "persistent";
          };
        };
      }
    ];
}
