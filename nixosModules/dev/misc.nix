{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Build Tools
    pkg-config
    gnumake

    # Java
    jdk

    # Math
    libqalculate

    # C/C++
    gcc

    # Android
    android-tools

    # Debug
    wev
  ];

  users.users.bean.extraGroups = ["wireshark"];
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };
}
