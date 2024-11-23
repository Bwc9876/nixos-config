{
  pkgs,
  inputs,
  config,
  target,
  ...
}: let
  sunsetCmd = "${pkgs.wlsunset}/bin/wlsunset -S 6:00 -s 22:00";
  screenOffCmd = "hyprctl dispatch dpms off; ${pkgs.swaynotificationcenter}/bin/swaync-client --inhibitor-add \"timeout\"; pkill wlsunset;";
  screenOnCmd = "hyprctl dispatch dpms on; ${pkgs.swaynotificationcenter}/bin/swaync-client --inhibitor-remove \"timeout\"; ${sunsetCmd};";
in {
  home-manager.users.bean = {
    wayland.windowManager.hyprland.settings = {
      exec-once = [
        sunsetCmd
        ''${inputs.wayland-mpris-idle-inhibit.packages.${target}.default}/bin/wayland-mpris-idle-inhibit --ignore "kdeconnect" --ignore "playerctld"''
      ];

      bindl = [
        ",switch:on:Lid Switch,exec,${screenOffCmd}"
        ",switch:off:Lid Switch,exec,${screenOnCmd}"
      ];
    };

    xdg.configFile."hypr/hypridle.conf".text = ''
      general {
          lock_cmd = pidof hyprlock || hyprlock
          unlock_cmd = pkill hyprlock --signal SIGUSR1
          before_sleep_cmd = loginctl lock-session
          after_sleep_cmd = hyprctl dispatch dpms on
      }

      listener {
          timeout = 120
          on-timeout = loginctl lock-session
      }

      listener {
          timeout = 300
          on-timeout = ${screenOffCmd}
          on-resume = ${screenOnCmd}
      }

      listener {
          timeout = 600
          on-timeout = systemctl suspend
      }
    '';
  };
}
