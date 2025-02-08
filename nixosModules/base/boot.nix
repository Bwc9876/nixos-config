{lib, ...}: {
  # /tmp should be clean!
  boot.tmp.cleanOnBoot = true;

  # Give me back my RAM!
  services.logind.extraConfig = ''
    RuntimeDirectorySize=100M
  '';

  # Don't do Wait Online
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.network.wait-online.enable = false;
}
