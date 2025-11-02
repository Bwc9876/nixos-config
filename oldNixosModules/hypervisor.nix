{
  pkgs,
  inputs,
  ...
}: {
  users.users.bean.extraGroups = ["libvirtd"];

  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true; # Win 11 needs TPM
    onBoot = "ignore"; # I don't want VMs to start again on reboot
  };
}
