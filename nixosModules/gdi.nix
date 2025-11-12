{...}: {
  config,
  lib,
  pkgs,
  ...
}: {
  options.cow.gdi = {
    enable = lib.mkEnableOption "Hyprland with graphical apps, etc.";
    doIdle = lib.mkEnableOption "Idling the system";
    showGreet = lib.mkEnableOption "Show a greeter interface that runs a Wayland window manager";
  };

  config = lib.mkIf config.cow.gdi.enable {
    environment.pathsToLink = [
      "/share/applications"
      "/share/xdg-desktop-portal"
    ];

    services.greetd = lib.mkIf config.cow.gdi.showGreet {
      enable = true;
      useTextGreeter = true;
      settings.default_session.command = let
        greeting = ''--greeting "Authenticate into ${lib.toUpper config.networking.hostName}"'';
      in "${pkgs.tuigreet}/bin/tuigreet --time ${greeting} --cmd niri-session";
    };
  };
}
