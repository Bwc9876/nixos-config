{
  pkgs,
  lib,
  ...
}: {
  boot = {
    initrd.systemd = {
      enable = lib.mkDefault true;
    };

    # Use latest kernel with sysrqs and lockdown enabled
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    kernelParams = lib.mkDefault ["lockdown=confidentiality"];
    kernel.sysctl."kernel.sysrq" = 1;
  };
}
