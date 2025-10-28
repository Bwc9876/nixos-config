{modulesPath, ...}: {
  imports = ["${modulesPath}/virtualisation/qemu-vm.nix"];
  services.qemuGuest.enable = true;
}
