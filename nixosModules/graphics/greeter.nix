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
        cmd = ''--cmd "systemd-inhibit --what=handle-power-key:handle-lid-switch Hyprland"'';
      in {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --remember --time ${greeting} ${cmd}";
      };
    };
  };
}
