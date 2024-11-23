{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    chromium

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
