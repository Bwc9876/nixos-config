{pkgs, ...}: {
  # Desktop entry to launch htop
  home-manager.users.bean.xdg.dataFile."applications/htop.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=Htop
    Exec=foot --title="Htop" --app-id="htop" htop
    Icon=htop
  '';

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
