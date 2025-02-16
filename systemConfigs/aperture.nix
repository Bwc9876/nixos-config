{
  inputs,
  outputs,
  ...
}: {
  system = "x86_64-linux";

  modules = [
    (outputs.lib.applyRoles ["base" "latest-linux" "dev" "graphics" "games" "fun" "social" "imperm" "secureboot" "wireless" "hypervisor" "podman"])
    inputs.nixos-hardware.nixosModules.framework-13th-gen-intel

    (
      {
        config,
        lib,
        pkgs,
        modulesPath,
        inputs,
        outputs,
        ...
      }: {
        system.stateVersion = "25.05";
        networking.hostName = "aperture";

        services.fprintd.enable = true;

        boot.initrd.availableKernelModules = ["xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod"];
        boot.initrd.kernelModules = [];
        boot.kernelModules = ["kvm-intel"];
        boot.extraModulePackages = [];
        boot.binfmt.emulatedSystems = ["aarch64-linux"];

        hardware.framework.enableKmod = false;

        fileSystems."/" = {
          fsType = "tmpfs";
          options = ["size=512M" "mode=755"];
          neededForBoot = true;
        };

        fileSystems."/home" = {
          fsType = "tmpfs";
          options = ["size=2G"];
          neededForBoot = true;
        };

        fileSystems."/boot" = {
          device = "/dev/disk/by-uuid/88E4-A64F";
          fsType = "vfat";
          options = ["fmask=0022" "dmask=0022" "nosuid" "nodev" "noexec" "noatime"];
        };

        fileSystems."/nix" = {
          device = "/dev/disk/by-uuid/fd9f484a-a5ef-4378-b054-d292b0204afb";
          fsType = "ext4";
          options = ["lazytime" "nodev" "nosuid"];
          neededForBoot = true;
        };

        boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-uuid/330c8e83-23cd-46bf-99b3-75a7f5d7c5dc";
        boot.initrd.luks.devices."cryptswap".device = "/dev/disk/by-uuid/c599ad48-750b-458d-8361-601bee3eb066";

        swapDevices = [
          {device = "/dev/disk/by-uuid/834d0d23-6a06-416f-853f-36c6ce81f355";}
        ];

        networking.useDHCP = lib.mkDefault true;

        powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
        hardware.enableRedistributableFirmware = lib.mkDefault true;
        hardware.cpu.intel.updateMicrocode =
          lib.mkDefault config.hardware.enableRedistributableFirmware;
      }
    )
  ];
}
