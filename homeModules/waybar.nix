{inputs, ...}: {
  config,
  lib,
  pkgs,
  ...
}: {
  options.cow.waybar.enable =
    lib.mkEnableOption "Waybar + customizations"
    // {
      default = config.cow.gdi.enable;
    };

  config = lib.mkIf config.cow.waybar.enable (
    lib.mkMerge [
      (lib.mkIf config.cow.cat.enable {
        # To stop IFD
        catppuccin.waybar.mode = "createLink";
        programs.waybar.style = ../res/waybar.css;
      })
      {
        programs.waybar = {
          enable = true;
          systemd.enable = true;
          settings = [
            {
              battery = {
                format = "{icon} {capacity}󰏰";
                format-charging = "{icon} {capacity}󰏰";
                format-icons = {
                  charging = [
                    "󰢜"
                    "󰂆"
                    "󰂇"
                    "󰂈"
                    "󰢝"
                    "󰂉"
                    "󰢞"
                    "󰂊"
                    "󰂋"
                    "󰂅"
                  ];
                  default = [
                    "󰁺"
                    "󰁻"
                    "󰁼"
                    "󰁽"
                    "󰁾"
                    "󰁿"
                    "󰂀"
                    "󰂁"
                    "󰂂"
                    "󰁹"
                  ];
                };
                states = {
                  critical = 15;
                  warning = 30;
                };
              };
              bluetooth = {
                format = "󰂯";
                format-connected = "󰂱";
                format-connected-battery = "󰂱 {device_battery_percentage}󰏰";
                format-disabled = "󰂲";
                format-off = "󰂲";
                on-click-right = "rfkill toggle bluetooth";
                tooltip-format = "{controller_alias}\t{controller_address}\n\n{num_connections} connected";
                tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}";
                tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
                tooltip-format-enumerate-connected-battery = "{device_alias}\t{device_address}\t{device_battery_percentage}%";
              };
              "clock#1" = {
                actions = {
                  on-click = "shift_up";
                  on-click-middle = "mode";
                  on-click-right = "shift_down";
                };
                calendar = {
                  format = {
                    days = "<span color='#ecc6d9'><b>{}</b></span>";
                    months = "<span color='#ffead3'><b>{}</b></span>";
                    today = "<span color='#ff6699'><b><u>{}</u></b></span>";
                    weekdays = "<span color='#ffcc66'><b>{}</b></span>";
                    weeks = "<span color='#99ffdd'><b>W{}</b></span>";
                  };
                  mode = "month";
                  mode-mon-col = 3;
                  on-scroll = 1;
                  weeks-pos = "right";
                };
                format = "󰃭 {:%A, %B %Od}";
                tooltip-format = "<tt><small>{calendar}</small></tt>";
              };
              "clock#2" = {
                format = "󰥔 {:%I:%M %p}";
                tooltip-format = "{:%F at %T in %Z (UTC%Ez)}";
              };
              "custom/kde-connect" = {
                exec = ''${pkgs.nushell}/bin/nu --plugins "[${
                    lib.getExe inputs.nu_plugin_dbus.packages.${pkgs.system}.default
                  }]" ${../res/custom_waybar_modules/kdeconnect.nu}'';
                format = "{}";
                interval = 30;
                on-click = "kdeconnect-settings";
                return-type = "json";
              };
              "custom/news" = {
                exec = "${pkgs.nushell}/bin/nu ${../res/custom_waybar_modules/newsboat.nu}";
                exec-on-event = true;
                format = "{}";
                on-click-right = "pkill waybar -SIGRTMIN+6";
                restart-interval = 1800;
                return-type = "json";
                signal = 6;
              };
              "custom/notification" = {
                escape = true;
                exec = "swaync-client -swb";
                exec-if = "which swaync-client";
                format = "{icon}";
                format-icons = {
                  dnd-inhibited-none = "󰂛";
                  dnd-inhibited-notification = "󰂛<sup></sup>";
                  dnd-none = "󰂛";
                  dnd-notification = "󰂛<sup></sup>";
                  inhibited-none = "󰂠";
                  inhibited-notification = "󰂠<sup></sup>";
                  none = "󰂚";
                  notification = "󱅫";
                };
                max-length = 3;
                on-click = "sleep 0.2 && swaync-client -t -sw";
                on-click-middle = "sleep 0.2 && swaync-client -C -sw";
                on-click-right = "sleep 0.2 && swaync-client -d -sw";
                return-type = "json";
                tooltip = false;
              };
              "custom/weather" = {
                exec = "${pkgs.nushell}/bin/nu ${../res/custom_waybar_modules/weather.nu}";
                format = "{}";
                interval = 600;
                on-click = "xdg-open https://duckduckgo.com/?q=weather";
                return-type = "json";
              };
              idle_inhibitor = {
                format = "{icon}";
                format-icons = {
                  activated = "󰒳";
                  deactivated = "󰒲";
                };
              };
              layer = "top";
              modules-center = [];
              modules-left =
                [
                  "user"
                  "clock#1"
                  "clock#2"
                ]
                ++ lib.optional config.cow.news.enable "custom/news"
                ++ [
                  "custom/weather"
                ];
              modules-right =
                [
                  "network"
                  "battery"
                  "bluetooth"
                  "pulseaudio"
                ]
                ++ lib.optional config.cow.kde-connect.enable "custom/kde-connect"
                ++ lib.optional config.cow.gdi.doIdle "idle_inhibitor"
                ++ [
                  "custom/notification"
                  "privacy"
                  "tray"
                ];

              network = {
                format = "{ifname}";
                format-disconnected = "󰪎";
                format-ethernet = "󱎔 {ifname}";
                format-icons = [
                  "󰤟"
                  "󰤢"
                  "󰤥"
                  "󰤨"
                ];
                format-linked = "󰌷 {ifname}";
                format-wifi = "{icon} {essid}";
                tooltip-disconnected = "Disconnected";
                tooltip-format = "{ifname} via {gwaddr}";
                tooltip-format-ethernet = "󱎔 {ifname}";
                tooltip-format-wifi = "Connected to {essid} ({signalStrength}󰏰 Strength) over {ifname} via {gwaddr}";
              };
              position = "top";
              privacy = {
                icon-size = 20;
                icon-spacing = 4;
                modules = [
                  {
                    tooltip = true;
                    tooltip-icon-size = 24;
                    type = "screenshare";
                  }
                  {
                    tooltip = true;
                    tooltip-icon-size = 24;
                    type = "audio-in";
                  }
                ];
                transition-duration = 200;
              };
              pulseaudio = {
                format = "{icon} {volume:2}󰏰";
                format-bluetooth = "{icon}  {volume}󰏰";
                format-icons = {
                  car = "";
                  default = [
                    "󰖀"
                    "󰕾"
                  ];
                  hands-free = "󰋋";
                  headphone = "󰋋";
                  headset = "󰋋";
                  phone = "";
                  portable = "";
                };
                format-muted = "󰝟";
                on-click = "pamixer -t";
                on-click-right = "pavucontrol";
                scroll-step = 5;
              };
              tray = {
                icon-size = 25;
                show-passive-items = true;
                spacing = 5;
              };
              user = {
                format = " {user}";
                icon = true;
              };
            }
            {
              mpris = {
                album-len = 20;
                artist-len = 25;
                interval = 1;
                dynamic-importance-order = [
                  "title"
                  "position"
                  "length"
                  "artist"
                  "album"
                ];
                dynamic-len = 80;
                dynamic-order = [
                  "title"
                  "artist"
                  "album"
                  "position"
                  "length"
                ];
                format = "{player_icon} {dynamic}";
                format-paused = "{status_icon} {dynamic}";
                player-icons = {
                  QMPlay2 = "󰐌";
                  default = "󰎆";
                  firefox = "";
                  firefox-devedition = "";
                  chromium = "󰖟";
                  kdeconnect = "";
                  spotify = "󰓇";
                };
                status-icons = {
                  paused = "󰏤";
                  stopped = "󰓛";
                };
                title-len = 35;
              };
              cpu = {
                format = "󰍛 {usage}󰏰";
                states = {
                  critical = 95;
                  warning = 80;
                };
              };
              "hyprland/workspaces" = {
                disable-scroll = true;
                format = "{name}";
              };
              layer = "top";
              memory = {
                format = " {}󰏰 ({used:0.1f}/{total:0.1f} GiB)";
                states = {
                  critical = 90;
                  warning = 70;
                };
              };
              # modules-center = ["wlr/taskbar"];
              modules-left = ["mpris"];
              modules-right = [
                "temperature"
                "cpu"
                "power-profiles-daemon"
                "memory"
              ];
              position = "bottom";
              temperature = {
                critical-threshold = 80;
                format = "{icon} {temperatureC} °C";
                format-critical = "{icon}! {temperatureC} °C";
                format-icons = [
                  "󱃃"
                  "󰔏"
                  "󱃂"
                ];
                thermal-zone = 1;
              };
              "wlr/taskbar" = {
                format = "{icon}";
                icon-size = 35;
                on-click = "activate";
              };
              power-profiles-daemon = {
                format = "{icon}";
                tooltip-format = "Power Profile: {profile}";
                format-icons = {
                  default = "󰓅";
                  performance = "󰓅";
                  balanced = "󰾅";
                  power-saver = "󰾆";
                };
              };
            }
          ];
        };
      }
    ]
  );
}
