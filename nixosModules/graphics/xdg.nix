{
  config,
  lib,
  ...
}: {
  home-manager.users.bean.xdg = {
    enable = true;
    userDirs = let
      inherit (config.home-manager.users.bean.home) homeDirectory;
    in {
      enable = true;
      createDirectories = true;
      desktop = "${homeDirectory}/Desktop";
      documents = "${homeDirectory}/Documents";
      pictures = "${homeDirectory}/Pictures";
      videos = "${homeDirectory}/Videos";
      music = "${homeDirectory}/Music";
      extraConfig = {
        "XDG_SCREENSHOTS_DIR" = "${homeDirectory}/Pictures/Screenshots";
      };
    };
    mimeApps = {
      enable = true;
      defaultApplications = let
        types = {
          browser = [
            "text/html"
            "application/pdf"
            "x-scheme-handler/http"
            "x-scheme-handler/https"
            "x-scheme-handler/ftp"
            "x-scheme-handler/about"
            "x-scheme-handler/unknown"
          ];
          code = [
            "application/json"
            "application/xml"
            "application/yaml"
            "text/english"
            "text/plain"
            "text/x-makefile"
            "text/x-c++hdr"
            "text/x-c++src"
            "text/x-chdr"
            "text/x-csrc"
            "text/x-java"
            "text/x-moc"
            "text/x-pascal"
            "text/x-tcl"
            "text/x-tex"
            "text/x-rust"
            "application/x-shellscript"
            "text/x-c"
            "text/x-c++"
          ];
          image = ["image/*"];
          av = [
            "video/*"
            "audio/*"
          ];
          dir = ["inode/directory"];
        };
        fileBrowsers = ["org.kde.dolphin.desktop"];
        textEditors = [
          "neovide.desktop"
          "nvim.desktop"
        ];
        browsers = [
          "floorp.desktop"
          "chromium.desktop"
        ];
        imageViewers =
          [
            "org.gnome.Loupe.desktop"
            "gimp.desktop"
          ]
          ++ browsers;
        avPlayers =
          [
            "QMPlay2.desktop"
          ]
          ++ browsers;
        genTypeHandler = type: handlers: lib.genAttrs type (_: handlers);
      in
        (genTypeHandler types.code textEditors)
        // (genTypeHandler types.av avPlayers)
        // (genTypeHandler types.image imageViewers)
        // (genTypeHandler types.dir fileBrowsers)
        // (genTypeHandler types.browser browsers);
    };
  };
}
