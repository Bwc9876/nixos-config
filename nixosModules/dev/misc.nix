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

    # C/C++
    gcc

    # Android
    android-tools

    # Debug
    wev
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
