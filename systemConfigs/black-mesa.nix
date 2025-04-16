{
  outputs,
  inputs,
  ...
}: {
  system = "x86_64-linux";

  modules = [
    (outputs.lib.applyRoles ["base" "latest-linux" "wireless" "ssh" "graphics" "games" "fun" "dev" "normalboot" "mc-server"])
    {
      imports = [inputs.bingus.nixosModules.default];
      nixpkgs.overlays = [inputs.bingus.overlays.default];

      services.bingus-bot = {
        enable = true;
        replyChannels = [1295447496948191262 1295245646542143489];
      };
    }
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

      fileSystems."/" = {
        device = "/dev/nvme0n1p2";
        fsType = "ext4";
      };

      fileSystems."/boot" = {
        device = "/dev/nvme0n1p1";
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

      # services.nix-serve = {
      #   enable = true;
      #   secretKeyFile = "/etc/nix-serve-key";
      #   openFirewall = true;
      # };
    })
  ];
}
