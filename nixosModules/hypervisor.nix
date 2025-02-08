{
  pkgs,
  inputs,
  ...
}: {
  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore"; # I don't want VMs to start again on reboot
  };
}
