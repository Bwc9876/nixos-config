{...}: {
  config,
  lib,
  ...
}: {
  options.cow.disks = {
    enable = lib.mkEnableOption "allowing cow to create a UEFI-compatible layout";
    swap = lib.mkEnableOption "look for and swapon a swap device";
    luks = lib.mkEnableOption "do dev mapping for encrypted LUKS volumes";
    partition-prefix = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "A prefix to place before partition names (more multiboots, etc.)";
    };
  };

  config = let
    conf = config.cow.disks;
    prefix =
      if conf.partition-prefix == null
      then ""
      else "${conf.partition-prefix}-";
    primaryPart = "/dev/disk/by-partlabel/${prefix}NIXOS";
    swapPart = "/dev/disk/by-partlabel/${prefix}SWAP";
    bootPart = "/dev/disk/by-partlabel/${prefix}BOOT";
    cryptroot = "/dev/mapper/cryptroot";
    cryptswap = "/dev/mapper/cryptswap";
  in
    lib.mkIf config.cow.disks.enable {
      boot.initrd.kernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      boot.initrd.luks.devices = lib.mkIf conf.luks {
        "cryptroot" = {
          device = primaryPart;
        };
        "cryptswap" = {
          device = swapPart;
        };
      };
      swapDevices = [
        {
          device =
            if conf.luks
            then cryptswap
            else swapPart;
        }
      ];
      fileSystems."/boot" = {
        device = bootPart; # Boot partition is always unencrypted
        fsType = "vfat";
        options = [
          "fmask=0022"
          "dmask=0022"
          "nosuid"
          "nodev"
          "noexec"
          "noatime"
        ];
      };
      fileSystems."/nix" = lib.mkIf config.cow.imperm.enable {
        device =
          if conf.luks
          then cryptroot
          else primaryPart;
        fsType = "ext4";
        options = [
          "lazytime"
          "nodev"
          "nosuid"
        ];
        neededForBoot = true;
      };
      fileSystems."/" =
        if config.cow.imperm.enable
        then {
          fsType = "tmpfs";
          options = [
            "size=512M"
            "mode=755"
          ];
          neededForBoot = true;
        }
        else {
          device =
            if conf.luks
            then cryptroot
            else primaryPart;
          fsType = "ext4";
        };
      fileSystems."/home" = lib.mkIf config.cow.imperm.enable {
        fsType = "tmpfs";
        options = [
          "size=2G"
        ];
        neededForBoot = true;
      };
    };
}
