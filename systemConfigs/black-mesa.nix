{outputs, ...}: {
  system = "x86_64-linux";

  modules = [
    (outputs.lib.applyRoles ["base" "latest-linux" "wireless" "ssh" "fun" "dev" "secureboot" "mc-server"])
    ({
      modulesPath,
      lib,
      config,
      pkgs,
      ...
    }: {
      imports = [(modulesPath + "/installer/scan/not-detected.nix")];
      networking.hostName = "black-mesa";
      system.stateVersion = "25.05";

      boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod"];
      boot.initrd.kernelModules = ["amdgpu"];
      boot.kernelModules = ["kvm-amd"];
      boot.extraModulePackages = [];

      services.pulseaudio.enable = false;

      security.rtkit.enable = true; # Allows pipewire and friends to run realtime

      programs.nix-ld = {
        enable = true;
      };

      services.pipewire = {
        enable = true;
        pulse.enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
      };

      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
      };

      programs.gamescope = {
        enable = true;
        package = pkgs.gamescope.overrideAttrs (new: old: {
          src = pkgs.fetchFromGitHub {
            owner = "ValveSoftware";
            repo = "gamescope";
            rev = "186f3a3ed0ce8eb5f3a956d3916a3331ea4e3ab2";
            fetchSubmodules = true;
            hash = "sha256-zAzIi3syJYtbKjydp19d1OxZvMjXb+eO+mXT/mJPEuA=";
          };
        });
        capSysNice = true;
      };

      environment.systemPackages = with pkgs; [
        cage
        uwsm
      ];

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
      services.xserver.videoDrivers = ["amdgpu"];

      networking.interfaces.enp4s0.wakeOnLan.enable = true;

      services.nix-serve = {
        enable = true;
        secretKeyFile = "/etc/nix-serve-key";
        openFirewall = true;
      };
    })
  ];
}
