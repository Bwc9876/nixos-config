{ ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.cow.hypervisor = {
    enable = lib.mkEnableOption "Enable running VMs";
  };

  config = lib.mkIf config.cow.hypervisor.enable {
    users.users.bean.extraGroups = lib.mkIf config.cow.bean.enable [ "libvirtd" ];

    cow.imperm.keep = [ "/var/lib/libvirt" ];

    programs.virt-manager.enable = config.cow.gdi.enable;

    environment.systemPackages = with pkgs; [
      libtpms # For win 11
    ];

    virtualisation.libvirtd = {
      enable = true;
      qemu.swtpm.enable = true; # Win 11
      onBoot = "ignore"; # I don't want VMs to start again on reboot
    };
  };
}
