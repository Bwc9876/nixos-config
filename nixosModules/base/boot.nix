{lib, ...}: {
  # /tmp should be clean!
  boot.tmp.cleanOnBoot = true;

  # Give me back my RAM!
  services.logind.extraConfig = ''
    RuntimeDirectorySize=100M
  '';
}
