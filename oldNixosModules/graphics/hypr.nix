{pkgs, ...}: {
  environment = {
    systemPackages = with pkgs; [
      hyprpicker
      uwsm
    ];
    variables = {
      NIXOS_OZONE_WL = "1";
      _JAVA_AWT_WM_NONEREPARENTING = "1";
      GDK_BACKEND = "wayland,x11";
      ANKI_WAYLAND = "1";
      MOZ_ENABLE_WAYLAND = "1";
      XDG_SESSION_TYPE = "wayland";
      SDL_VIDEODRIVER = "wayland";
      CLUTTER_BACKEND = "wayland";
    };
  };

  xdg.portal.extraPortals = with pkgs; [xdg-desktop-portal-gtk];

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  home-manager.users.bean = {
    wayland.systemd.target = "wayland-session@hyprland.desktop.target";
  };
}
