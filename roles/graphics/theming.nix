{
  pkgs,
  inputs,
  ...
}: {
  qt = {
    enable = true;
    platformTheme = "qt5ct";
    style = "kvantum";
  };

  home-manager.users.bean = {
    qt = {
      enable = true;
      platformTheme.name = "kvantum";
      style.name = "kvantum";
    };

    xdg.configFile = {
      kdeglobals.source = "${inputs.self}/res/theming/kdeglobals";
      "qt5ct/qt5ct.conf".source = "${inputs.self}/res/theming/qt5ct.conf";
      "qt6ct/qt6ct.conf".source = "${inputs.self}/res/theming/qt6ct.conf";
      "gtk-3.0/settings.ini".source = "${inputs.self}/res/theming/gtk/settings.ini";
      "gtk-4.0/settings.ini".source = "${inputs.self}/res/theming/gtk/settings.ini";
    };

    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = "on";
        splash = false;
        preload = ["${inputs.self}/res/pictures/background.png"];
        wallpaper = [",${inputs.self}/res/pictures/background.png"];
      };
    };

    wayland.windowManager.hyprland.settings = {
      env = let
        cursorSize = "24";
      in [
        "QT_QPA_PLATFORM,wayland;xcb"
        "QT_AUTO_SCREEN_SCALE_FACTOR,1"
        "HYPRCURSOR_THEME,Sweet-cursors-hypr"
        "HYPRCURSOR_SIZE,${cursorSize}"
        "XCURSOR_THEME,Sweet-cursors"
        "XCURSOR_SIZE,${cursorSize}"
        "GRIMBLAST_EDITOR,swappy -f "
        "TERMINAL,foot"
      ];
      exec-once = [
        ''dconf write /org/gnome/desktop/interface/cursor-theme "Sweet-cursors"''
        ''dconf write /org/gnome/desktop/interface/icon-theme "candy-icons"''
        ''dconf write /org/gnome/desktop/interface/gtk-theme "Sweet-Ambar-Blue:dark"''
      ];
    };
  };

  fonts = {
    packages = with pkgs; [nerd-fonts.fira-code nerd-fonts.fira-mono noto-fonts noto-fonts-color-emoji liberation_ttf];
    fontconfig = {
      enable = true;
      defaultFonts = rec {
        serif = ["Noto Sans" "FiraCode Nerd Font" "Noto Color Emoji"];
        sansSerif = serif;
        monospace = ["FiraCode Nerd Font Mono" "Noto Color Emoji"];
        emoji = ["FiraCode Nerd Font" "Noto Color Emoji"];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    libsForQt5.qt5ct
    kdePackages.qt6ct
    libsForQt5.qtstyleplugin-kvantum
    kdePackages.qtstyleplugin-kvantum
    (callPackage "${inputs.self}/pkgs/theming.nix" {})
    adwaita-icon-theme # For fallback icons
  ];
}
