{lib, ...}: {
  # /tmp should be clean!
  boot.tmp.cleanOnBoot = true;

  # Don't do Wait Online
  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.network.wait-online.enable = false;
}
