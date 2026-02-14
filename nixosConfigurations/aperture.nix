{
  lib,
  inputs,
  outputs,
  ...
}: {
  system = "x86_64-linux";

  modules =
    (builtins.attrValues outputs.nixosModules)
    ++ [
      inputs.nixos-hardware.nixosModules.framework-13th-gen-intel
      (
        {pkgs, ...}: {
          home-manager.users.bean.home.stateVersion = "25.05";
          system.stateVersion = "25.05";
          networking.hostName = "aperture";

          users.users = let
            secureRoot = "/nix/persist/secure";
          in {
            bean = {
              hashedPasswordFile = "${secureRoot}/hashed-passwd";
              extraGroups = [
                "adbusers"
                "kvm"
              ];
            };
            root.hashedPasswordFile = "${secureRoot}/hashed-passwd";
          };

          home-manager.users.bean.cow = {
            kde-connect = {
              enable = true;
              dev-name = "APERTURE";
            };
            dev.mc = true;
          };

          services.keyd = {
            enable = true;
            keyboards.default.settings.main = {
              "capslock" = "7";
              "media" = "delete";
            };
          };

          home-manager.users.bean.programs.niri.settings = {
            outputs."eDP-1".scale = 1.25;
          };

          environment.systemPackages = with pkgs; [
            android-tools
          ];

          cow = {
            audio.tweaks = {
              enable = true;
              threadirqs = true;
              soundCard = "00:1f.3";
            };
            base.sysrqs = true;
            bean.sudoer = true;
            lanzaboote.enable = true;
            hypervisor.enable = true;
            role-laptop = {
              enable = true;
              fingerPrintSensor = true;
            };
            gaming.enable = true;
            imperm.enable = true;
            disks = {
              enable = true;
              swap = true;
              luks = true;
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
      )
    ];
}
