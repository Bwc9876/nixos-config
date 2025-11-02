{...}: {
  config,
  lib,
  pkgs,
  ...
}: {
  options.cow.gdi = {
    enable = lib.mkEnableOption "Hyprland with graphical apps, etc.";
    doIdle = lib.mkEnableOption "Idling the system";
    showGreet = lib.mkEnableOption "Show a greeter interface that runs UWSM to launch a Wayland window manager";
  };

  config = lib.mkIf config.cow.gdi.enable {
    environment = {
      systemPackages = with pkgs;
        lib.mkIf config.cow.gdi.showGreet [
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

    services.greetd = lib.mkIf config.cow.gdi.showGreet {
      enable = true;
      useTextGreeter = true;
      settings.default_session.command = let
        greeting = ''--greeting "Authenticate into ${lib.toUpper config.networking.hostName}"'';
        deCmd = pkgs.writeScript "start-session.sh" ''
          #!/usr/bin/env sh
          exec uwsm start ${pkgs.hyprland}/share/wayland-sessions/hyprland.desktop
        '';
        cmd = ''--cmd "systemd-inhibit --what=handle-power-key:handle-lid-switch ${deCmd}"'';
      in "${pkgs.tuigreet}/bin/tuigreet --time ${greeting} ${cmd}";
    };
  };
}
