{pkgs, ...}: {
  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true; # Win 11 needs TPM
    qemu.ovmf.packages = [
      (pkgs.OVMF.override {
        # I have to build UEFI firmware from source, fun times
        secureBoot = true; # Win 11 needs secure boot
        tpmSupport = true; # Win 11 needs TPM
      })
      .fd
    ];
  };

  # GUI For Managing Machines
  programs.virt-manager.enable = true;

  environment.systemPackages = with pkgs; [
    libtpms # For win 11
  ];
}
