{
  lib,
  config,
  inputs,
  outputs,
  ...
}: {
  system = "x86_64-linux";

  modules =
    (builtins.attrValues outputs.nixosModules)
    ++ [
      inputs.nixos-hardware.nixosModules.framework-13th-gen-intel
      {
        home-manager.users.bean.home.stateVersion = "25.05";
        system.stateVersion = "25.05";
        networking.hostName = "aperture";

        users.users = let
          secureRoot = "/nix/persist/secure";
        in {
          bean.password = "qaswedfr";
          # bean.hashedPasswordFile = "${secureRoot}/hashed-passwd";
          root.hashedPasswordFile = "${secureRoot}/hashed-passwd";
        };

        cow = {
          lanzaboote.enable = true;
          role-laptop = {
            enable = true;
            fingerPrintSensor = true;
          };
          gaming.enable = true;
          imperm.enable = true;
          disks = {
            enable = true;
            luks = true;
            swap = true;
          };
        };

        boot.initrd.availableKernelModules = [
          "xhci_pci"
          "thunderbolt"
          "nvme"
          "usb_storage"
          "sd_mod"
        ];
        boot.initrd.kernelModules = [];
        boot.kernelModules = ["kvm-intel"];
        boot.extraModulePackages = [];
        boot.binfmt.emulatedSystems = ["aarch64-linux"];

        hardware.framework.enableKmod = false;

        powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
        hardware.enableRedistributableFirmware = lib.mkDefault true;
        hardware.cpu.intel.updateMicrocode = true;
      }
    ];
}
