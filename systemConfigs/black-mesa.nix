{outputs, ...}: {
  system = "x86_64-linux";

  modules = [
    (outputs.lib.applyRoles ["base" "latest-linux" "ssh" "fun" "dev" "secureboot" "mc-server"])
    ({
      modulesPath,
      lib,
      config,
      ...
    }: {
      imports = [(modulesPath + "/installer/scan/not-detected.nix")];
      networking.hostName = "black-mesa";
      system.stateVersion = "25.05";

      boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
      boot.initrd.kernelModules = [];
      boot.kernelModules = ["kvm-amd"];
      boot.extraModulePackages = [];

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/77e539a3-813d-465b-ac11-8aad37300858";
        fsType = "ext4";
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/605A-7728";
        fsType = "vfat";
      };

      fileSystems."/mnt/storage" = {
        device = "/dev/sda1";
        fsType = "btrfs";
      };

      swapDevices = [];

      hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

      hardware.graphics.enable = true;

      networking.interfaces.enp4s0.wakeOnLan.enable = true;

      hardware.nvidia = {
        open = false;
        modesetting.enable = true;
        powerManagement.finegrained = false;
      };

      services.nix-serve = {
        enable = true;
        secretKeyFile = "/etc/nix-serve-key";
        openFirewall = true;
      };
    })
  ];
}
