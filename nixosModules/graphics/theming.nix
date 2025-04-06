{
  pkgs,
  lib,
  ...
}: let
  iconTheme = {
    name = "Tela-green";
    package = pkgs.tela-icon-theme;
  };
  cursorTheme = {
    name = "Qogir";
    package = pkgs.qogir-icon-theme;
    size = 24;
  };
  hyprThemeName = "${cursorTheme.name}-hypr";
  hyprCursorTheme = let
    utils = "${pkgs.hyprcursor}/bin/hyprcursor-util";
  in
    pkgs.runCommand hyprThemeName {} ''
      export PATH="$PATH:${pkgs.xcur2png}/bin"
      ${utils} -x ${cursorTheme.package}/share/icons/${cursorTheme.name} --output .
      mkdir -p $out/share/icons
      ${utils} -c ./extracted_${cursorTheme.name} --output .
      cp -r "./theme_Extracted Theme" $out/share/icons/${hyprThemeName}
    '';
in {
  environment.systemPackages = [
    hyprCursorTheme
    cursorTheme.package
    iconTheme.package
  ];

  qt = {
    enable = true;
    style = "kvantum";
  };

  home-manager.users.bean = {
    qt = {
      enable = true;
      platformTheme.name = "kvantum";
      style.name = "kvantum";
    };

    home.pointerCursor = {
      inherit (cursorTheme) name package size;
      enable = true;
      gtk.enable = true;
      x11.enable = true;
    };

    wayland.windowManager.hyprland.settings.env = [
      "HYPRCURSOR_THEME,${hyprThemeName}"
      "HYPRCURSOR_SIZE,${builtins.toJSON cursorTheme.size}"
    ];

    gtk = {
      enable = true;
      inherit iconTheme;
      gtk2.extraConfig = "gtk-application-prefer-dark-theme=true";
      gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
      gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
    };

    dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = "on";
        splash = false;
        preload = ["${../../res/pictures/background.png}"];
        wallpaper = [",${../../res/pictures/background.png}"];
      };
    };
  };
}
