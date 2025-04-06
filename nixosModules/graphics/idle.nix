{
  pkgs,
  inputs',
  ...
}: let
  sunsetCmd = "uwsm app -- ${pkgs.wlsunset}/bin/wlsunset -S 6:00 -s 22:00";
  screenOffCmd = "hyprctl dispatch dpms off; ${pkgs.swaynotificationcenter}/bin/swaync-client --inhibitor-add \"timeout\"; pkill wlsunset;";
  screenOnCmd = "hyprctl dispatch dpms on; ${pkgs.swaynotificationcenter}/bin/swaync-client --inhibitor-remove \"timeout\"; ${sunsetCmd};";
in {
  home-manager.users.bean = {
    wayland.windowManager.hyprland.settings = {
      exec-once = [
        sunsetCmd
        ''uwsm app -- ${inputs'.wayland-mpris-idle-inhibit.packages.default}/bin/wayland-mpris-idle-inhibit --ignore "kdeconnect" --ignore "playerctld"''
      ];

      bindl = [
        ",switch:on:Lid Switch,exec,${screenOffCmd}"
        ",switch:off:Lid Switch,exec,${screenOnCmd}"
      ];
    };

    services.hypridle = {
      enable = true;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock";
          unlock_cmd = "pkill hyprlock --signal SIGUSR1";
          before_sleep_cmd = "loginctl lock-session";
          after_sleep_cmd = "hyprctl dispatch dpms on";
        };

        listener = [
          {
            timeout = 120;
            on-timeout = "loginctl lock-session";
          }
          {
            timeout = 300;
            on-timeout = screenOffCmd;
            on-resume = screenOnCmd;
          }
          {
            timeout = 600;
            on-timeout = "systemctl suspend";
          }
        ];
      };
    };
  };
}
