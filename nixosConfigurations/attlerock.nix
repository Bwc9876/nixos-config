{
  lib,
  inputs,
  outputs,
  ...
}: {
  system = "x86_64-linux";

  modules = [
    outputs.nixosModules.default
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t430
    {
      home-manager.users.bean.home.stateVersion = "25.05";
      system.stateVersion = "25.05";
      networking.hostName = "attlerock";

      users.users = let
        secureRoot = "/nix/persist/secure";
      in {
        bean.hashedPasswordFile = "${secureRoot}/hashed-passwd";
        root.hashedPasswordFile = "${secureRoot}/hashed-passwd";
      };

      cow = {
        base.enable = true;
        hm.enable = true;
        network.enable = true;
        cat.enable = true;
        bean = {
          enable = true;
          sudoer = true;
        };
        lanzaboote.enable = true;
        imperm.enable = true;
        disks = {
          enable = true;
          swap = true;
        };
      };

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "ehci_pci"
        "ahci"
        "usb_storage"
        "sd_mod"
        "sr_mod"
        "sdhci_pci"
        "iwlwifi"
        "ec_sys"
        "thinkpad_acpi"
      ];
      boot.initrd.kernelModules = [];
      boot.kernelModules = ["kvm-intel"];
      boot.extraModulePackages = [];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.intel.updateMicrocode = true;
    }
  ];
}
