{config, ...}: {
  xdg.mime = {
    removedAssociations = {
      "inode/directory" = ["QMPlay2.desktop" "QMPlay2_enqueue.desktop"];
    };
    defaultApplications = {
      "application/pdf" = "firefox-devedition.desktop";
      "image/*" = ["org.gnome.Loupe.desktop" "firefox-devedition.desktop" "chromium-browser.desktop"];
      "text/*" = "neovide.desktop";
      "inode/directory" = "yazi.desktop";
    };
  };

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
  };
}
