{pkgs, ...}: {
  # Desktop entry to launch htop
  home-manager.users.bean.xdg.dataFile."applications/htop.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Htop
    Exec=foot --title="Htop" --app-id="htop" htop
    Icon=htop
  '';

  programs.kdeconnect.enable = true;

  systemd.user.services.kdeconnect = {
    description = "Adds communication between your desktop and your smartphone";
    after = ["graphical-session-pre.target"];
    partOf = ["graphical-session.target"];
    wantedBy = ["graphical-session.target"];
    serviceConfig = {
      #   Environment = "PATH=${config.home.profileDirectory}/bin";
      ExecStart = "${pkgs.libsForQt5.kdeconnect-kde}/libexec/kdeconnectd";
      Restart = "on-abort";
    };
  };

  environment.systemPackages = with pkgs; [
    chromium

    # Office
    libreoffice-qt6

    ## Media
    libsForQt5.kdenlive
    obs-studio
    qmplay2
    gimp
    inkscape
    lorien

    ## 3D
    prusa-slicer

    ## Music
    spotify
  ];
}
