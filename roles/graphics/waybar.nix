{
  pkgs,
  inputs,
  ...
}: let
  catppuccinCss = pkgs.fetchurl {
    url = "https://github.com/catppuccin/waybar/raw/refs/heads/main/themes/mocha.css";
    hash = "sha256-puMFl8zIKOiYhE6wzqnffXOHn/VnKmpVDzrMJMk+3Rc=";
  };
in {
  home-manager.users.bean = {
    wayland.windowManager.hyprland.settings.bind = [
      "SUPER,W,exec,pidof waybar || waybar"
      "SUPER SHIFT,W,exec,pkill waybar"
    ];
    programs.waybar = {
      enable = true;
      style = ''
        @import "${catppuccinCss}";

        * {
          font-family: sans-serif;
        }

        window#waybar {
          background: rgba(49, 50, 68, 0.65);
          color: @text;
        }

        .modules-left > * > *,
        .modules-right > * > * {
          font-size: 1.5rem;
          background: @crust;
          border: 2px solid @base;
          border-radius: 5rem;
          padding: 5px 15px;
          margin: 5px 2px;
        }

        #bluetooth.disabled {
          border-color: @red;
        }

        #waybar .modules-left > *:first-child > * {
          margin-left: 25px;
        }

        #waybar .modules-right > *:last-child > * {
          margin-right: 25px;
        }

        #waybar .modules-left,
        #waybar .modules-right {
          margin-top: 10px;
          margin-bottom: 5px;
        }

        #waybar .modules-center {
          margin-top: 5px;
          margin-bottom: 5px;
        }

        #battery.warning {
          border-color: @yellow;
        }

        #battery.critical {
          border-color: @red;
        }

        * > #battery.charging {
          border-color: @green;
        }

        #taskbar,
        #workspaces {
          padding: 10px;
          border-radius: 5rem;
          border: none;
          background: none;
        }

        #taskbar button,
        #workspaces button {
          color: @text;
          border-radius: 5rem;
          padding: 5px 15px;
          margin: 0 5px;
          background: @crust;
          border: 2px solid @base;
        }

        #taskbar button:hover, #workspaces button:hover {
          background: @mantle;
        }

        #workspaces button {
          font-size: 1.5rem;
        }

        #cpu,
        #memory,
        #temperature {
          font-size: 1.5rem;
          padding: 10px 25px;
        }

        #cpu.warning,
        #memory.warning {
            border-color: @yellow;
        }

        #cpu.critical,
        #memory.critical,
        #temperature.critical {
            border-color: @red;
        }

        #workspaces button.active {
          border: 2px solid @sapphire;
        }

        #taskbar button.active {
          border: 2px solid @sapphire;
        }

        #idle_inhibitor.activated {
          border-color: @mauve;
        }

        #custom-notification.notification {
          border-color: @sapphire;
        }

        #custom-notification.dnd-none,
        #custom-notification.dnd-notification,
        #custom-notification.dnd-inhibited-none,
        #custom-notification.dnd-inhibited-notification {
          border-color: @red;
        }

        #custom-notification.inhibited-none,
        #custom-notification.inhibited-notification {
          border-color: @mauve;
        }

        #network.disconnected {
          border-color: @red;
        }

        #privacy {
          background: none;
          border: none;
          margin: 0;
          padding: 0;
        }

        #privacy-item {
          font-size: 1.5rem;
          border-radius: 5rem;
          padding: 5px 15px;
          margin: 5px 2px;
          border: 2px solid @red;
          background-color: @crust;
        }

        #custom-weather.VeryCloudy,
        #custom-weather.Cloudy,
        #custom-weather.Fog {
          border-color: @overlay0;
        }

        #custom-weather.HeavyRain,
        #custom-weather.ThunderyHeavyRain,
        #custom-weather.ThunderyRain,
        #custom-weather.ThunderyShowers,
        #custom-weather.HeavyShowers,
        #custom-weather.LightRain,
        #custom-weather.LightShowers {
          border-color: @teal;
        }

        #custom-weather.HeavySnow,
        #custom-weather.LightSnow,
        #custom-weather.Sleet,
        #custom-weather.Snow,
        #custom-weather.LightSnowShowers,
        #custom-weather.LightSleetShowers {
          border-color: @text;
        }

        #custom-weather.Clear,
        #custom-weather.Sunny {
          border-color: @yellow;
        }

        #custom-weather.PartlyCloudy {
          border-color: @flamingo;
        }

        #custom-weather.PartlyCloudy.night {
          border-color: @lavender;
        }

        #custom-weather.Clear.night,
        #custom-weather.Sunny.night {
          border-color: @mauve;
        }

        #custom-news.utd {
          font-size: 1.5rem;
        }

        #custom-news.unread {
          border-color: @sapphire;
        }

        #mpris.playing {
          border-color: @sapphire;
        }

        #mpris.playing.spotify {
          border-color: #33B980;
        }

        #mpris.paused.kdeconnect {
          opacity: 0;
        }
      '';
      settings = [
        {
          battery = {
            format = "{icon} {capacity}󰏰";
            format-charging = "{icon} {capacity}󰏰";
            format-icons = {
              charging = ["󰢜" "󰂆" "󰂇" "󰂈" "󰢝" "󰂉" "󰢞" "󰂊" "󰂋" "󰂅"];
              default = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
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
            on-click = "rofi-bluetooth";
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
            exec = "${pkgs.nushell}/bin/nu ${inputs.self}/res/custom_waybar_modules/kdeconnect.nu";
            format = "{}";
            interval = 30;
            on-click = "kdeconnect-settings";
            return-type = "json";
          };
          "custom/news" = {
            exec = "${pkgs.nushell}/bin/nu ${inputs.self}/res/custom_waybar_modules/newsboat.nu";
            exec-on-event = true;
            format = "{}";
            on-click = "pidof -q newsboat && hyprctl dispatch focuswindow newsboat || foot --title=\"Newsboat\" --app-id=\"newsboat\" newsboat; pkill -SIGRTMIN+6 waybar";
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
            exec = "${pkgs.nushell}/bin/nu ${inputs.self}/res/custom_waybar_modules/weather.nu";
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
          modules-left = ["user" "clock#1" "clock#2" "custom/news" "custom/weather" "mpris"];
          modules-right = ["network" "battery" "bluetooth" "pulseaudio" "custom/kde-connect" "idle_inhibitor" "custom/notification" "privacy" "tray"];
          mpris = {
            album-len = 20;
            artist-len = 25;
            dynamic-importance-order = ["title" "position" "length" "artist" "album"];
            dynamic-len = 50;
            dynamic-order = ["title" "artist" "album" "position" "length"];
            format = "{player_icon} {dynamic}";
            format-paused = "{status_icon} {dynamic}";
            player-icons = {
              QMPlay2 = "󰐌";
              default = "󰎆";
              firefox = "󰈹";
              firefox-devedition = "󰈹";
              kdeconnect = "";
              spotify = "󰓇";
            };
            status-icons = {
              paused = "󰏤";
              stopped = "󰓛";
            };
            title-len = 35;
          };
          network = {
            format = "{ifname}";
            format-disconnected = "󰪎";
            format-ethernet = "󱎔 {ifname}";
            format-icons = ["󰤟" "󰤢" "󰤥" "󰤨"];
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
              default = ["󰖀" "󰕾"];
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
          cpu = {
            format = "󰍛 {usage}󰏰";
            on-click = "foot --title=\"Htop\" --app-id=\"htop\" htop --sort-key=PERCENT_CPU";
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
            on-click = "foot --title=\"Htop\" --app-id=\"htop\" htop --sort-key=PERCENT_MEM";
            states = {
              critical = 90;
              warning = 70;
            };
          };
          modules-center = ["wlr/taskbar"];
          modules-left = ["hyprland/workspaces"];
          modules-right = ["temperature" "cpu" "memory"];
          position = "bottom";
          temperature = {
            critical-threshold = 80;
            format = "{icon} {temperatureC} °C";
            format-critical = "{icon}! {temperatureC} °C";
            format-icons = ["󱃃" "󰔏" "󱃂"];
            thermal-zone = 1;
          };
          "wlr/taskbar" = {
            format = "{icon}";
            icon-size = 35;
            icon-theme = "candy-icons";
            on-click = "activate";
          };
        }
      ];
    };
  };
}
