{
  pkgs,
  config,
  lib,
  ...
}: {
  services.greetd = {
    enable = true;
    settings = {
      default_session = let
        greeting = ''--greeting "Authenticate into ${lib.toUpper config.networking.hostName}"'';
        deCmd = pkgs.writeScript "start-session.sh" ''
          #!/usr/bin/env sh
          exec uwsm start ${pkgs.hyprland}/share/wayland-sessions/hyprland.desktop
        '';
        cmd = ''--cmd "systemd-inhibit --what=handle-power-key:handle-lid-switch ${deCmd}"'';
      in {
        command = "${pkgs.tuigreet}/bin/tuigreet --remember --time ${greeting} ${cmd}";
      };
    };
  };
}
