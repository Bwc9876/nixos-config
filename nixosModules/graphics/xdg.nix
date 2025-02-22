{config, ...}: {
  home-manager.users.bean.xdg = {
    enable = true;
    userDirs = with config.home-manager.users.bean.home; {
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
        textEditors = ["neovide.desktop"];
        browsers = ["firefox-devedition.desktop" "firefox.desktop" "chromium.desktop"];
        imageViewers = ["gimp.desktop"];
      in {
        "inode/directory" = ["org.kde.dolphin.desktop"];
        "text/plain" = textEditors;
        "text/markdown" = textEditors;
        "text/xml" = textEditors;
        "text/x-markdown" = textEditors;
        "text/x-readme" = textEditors;
        "text/x-changelog" = textEditors;
        "text/x-copying" = textEditors;
        "text/x-install" = textEditors;
        "text/html" = browsers;
        "image/png" = imageViewers;
        "image/jpeg" = imageViewers;
        "image/gif" = browsers;
        "image/bmp" = imageViewers;
        "image/x-portable-pixmap" = imageViewers;
        "image/x-portable-bitmap" = imageViewers;
        "image/x-portable-graymap" = imageViewers;
        "image/x-portable-anymap" = imageViewers;
        "image/svg+xml" = imageViewers;
        "x-terminal-emulator" = ["wezterm.desktop"];
        "x-scheme-handler/http" = browsers;
        "x-scheme-handler/https" = browsers;
        "x-scheme-handler/chrome" = browsers;
        "x-scheme-handler/vscode" = ["code-url-handler.desktop"];
        "x-scheme-handler/x-github-client" = ["github-desktop.desktop"];
        "x-scheme-handler/x-github-desktop-auth" = ["github-desktop.desktop"];
        "application/x-extension-htm" = browsers;
        "application/x-extension-html" = browsers;
        "application/x-extension-shtml" = browsers;
        "application/x-extension-xht" = browsers;
        "application/x-extension-xhtml" = browsers;
        "application/xhtml+xml" = browsers;
        "application/xml" = browsers;
        "application/pdf" = browsers;
      };
    };
  };
}
