{
  target = "x86_64-linux";
  extraOverlays = [];

  eval = {inputs, ...}: {
    description = "Framework 13 Laptop";

    edition = "25.05";

    includeBaseMods = true;

    roles = ["latest-linux" "dev" "graphics" "games" "fun" "social" "secureboot" "wireless" "hypervisor"];
    extraModules = [
      inputs.nixos-hardware.nixosModules.framework-13th-gen-intel
      (
        {
          config,
          lib,
          pkgs,
          modulesPath,
          ...
        }: {
          imports = [(modulesPath + "/installer/scan/not-detected.nix")];

          boot.initrd.availableKernelModules = ["xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod"];
          boot.initrd.kernelModules = [];
          boot.kernelModules = ["kvm-intel"];
          boot.extraModulePackages = [];
          boot.binfmt.emulatedSystems = ["aarch64-linux"];

          fileSystems."/" = {
            device = "/dev/disk/by-uuid/2c002966-4572-4094-8d3f-18d455b611ca";
            fsType = "ext4";
          };

          fileSystems."/boot" = {
            device = "/dev/disk/by-uuid/A57C-E5FF";
            fsType = "vfat";
          };

          hardware.framework.enableKmod = false;

          swapDevices = [{device = "/dev/disk/by-uuid/fde5784f-93e8-4e3b-8ca2-74bf44b00479";}];

          # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
          # (the default) this is the recommended approach. When using systemd-networkd it's
          # still possible to use this option, but it's recommended to use it in conjunction
          # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
          networking.useDHCP = lib.mkDefault true;
          # networking.interfaces.wlp170s0.useDHCP = lib.mkDefault true;

          nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
          powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
          hardware.cpu.intel.updateMicrocode =
            lib.mkDefault config.hardware.enableRedistributableFirmware;
        }
      )
    ];
  };
}
