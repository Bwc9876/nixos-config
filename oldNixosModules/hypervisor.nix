{
  pkgs,
  inputs,
  ...
}: {
  users.users.bean.extraGroups = ["libvirtd"];

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore"; # I don't want VMs to start again on reboot
  };
}
