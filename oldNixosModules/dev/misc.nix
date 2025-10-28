{
  pkgs,
  inputs',
  ...
}: {
  environment.systemPackages = with pkgs; [
    # Build Tools
    pkg-config
    gnumake

    # Java
    jdk

    # Math
    libqalculate

    # Misc Misc
    binutils
    usbutils
    qrencode
    nmap
    file
    procfd
    ldapvi
    dust
    zip
    p7zip
    wol

    # C/C++
    gcc
    gdb

    # Windows
    wine-wayland

    # Android
    android-tools

    # Debug
    wev
    poop
    inputs'.gh-grader-preview.packages.default
  ];

  users.users.bean.extraGroups = ["wireshark"];
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  # home-manager.users.bean.programs.direnv = {
  #   enable = true;
  #   enableBashIntegration = true;
  #   enableNushellIntegration = true;
  #   nix-direnv.enable = true;
  #   silent = true;
  # };
}
