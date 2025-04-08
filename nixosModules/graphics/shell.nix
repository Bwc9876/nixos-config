{
  pkgs,
  config,
  lib,
  inputs',
  ...
}: {
  users.users.bean.extraGroups = ["video"];

  nixpkgs.overlays = [
    (next: prev: {
      wl-clipboard = prev.wl-clipboard.overrideAttrs {
        src = pkgs.fetchFromGitHub {
          owner = "bugaevc";
          repo = "wl-clipboard";
          rev = "424517085c45849edfeff72a4e3cc0724f54404a";
          sha256 = "sha256-SueQw+/fR9B7Vbw4SvkaBN8Ifu1dMp3ymDr3a0lTdSs=";
        };
      };
    })
  ];

  environment.systemPackages = with pkgs; [
    # Shell Components
    hyprlock
    hyprland-qtutils

    ## Waybar
    qt6.qttools # For component

    ## Dolphin
    kdePackages.dolphin
    kdePackages.ark # For archive support
    kdePackages.kio-extras # For thumbnails
    kdePackages.kdegraphics-thumbnailers # For thumbnails

    pavucontrol

    wf-recorder
    slurp
    grim
    xdg-utils
    grimblast
    tesseract
    swappy
    libnotify
    swaynotificationcenter
    networkmanagerapplet
    wl-clipboard

    keepassxc

    hunspell
    hunspellDicts.en_US
    hunspellDicts.en_US-large
  ];

  services.udisks2.enable = true;

  home-manager.users.bean = let
    screenOffCmd = "hyprctl dispatch dpms off; ${pkgs.swaynotificationcenter}/bin/swaync-client --inhibitor-add \"timeout\"";
    screenOnCmd = "hyprctl dispatch dpms on; ${pkgs.swaynotificationcenter}/bin/swaync-client --inhibitor-remove \"timeout\"";
  in {
    xdg.configFile = {
      "swappy/config".text = ''
        [Default]
        save_dir=$HOME/Pictures/Screenshots
        save_filename_format=%Y-%m-%dT%H:%M:%S-edited.png
        show_panel=true
        line_size=5
        text_size=20
        text_font=monospace
        paint_mode=brush
        early_exit=false
        fill_shape=false
      '';
      "kdeconnect/config".text = ''
        [General]
        name=${lib.toUpper config.networking.hostName}
      '';
    };

    # Doing our own thing for rofi
    catppuccin.rofi.enable = false;

    systemd.user.services = let
      target = config.home-manager.users.bean.wayland.systemd.target;
      mkShellService = {
        desc,
        service,
      }: {
        Install = {WantedBy = [target];};

        Unit = {
          ConditionEnvironment = "WAYLAND_DISPLAY";
          Description = desc;
          After = [target];
          PartOf = [target];
        };

        Service = service;
      };
    in {
      dolphin = mkShellService {
        desc = "Dolphin File Manager Daemon";

        service = {
          ExecStart = "${pkgs.kdePackages.dolphin}/bin/dolphin --daemon";
          Restart = "on-failure";
          RestartSec = "10";
          BusName = "org.freedesktop.FileManager1";
        };
      };

      battery-notif = mkShellService {
        desc = "Batter Notification Service";

        service = {
          ExecStart = "${pkgs.nushell}/bin/nu ${../../res/battery_notif.nu}";
          Restart = "on-failure";
          RestartSec = "10";
        };
      };

      mpris-idle-inhibit = mkShellService {
        desc = "MPRIS Idle Inhibitor";

        service = {
          ExecStart = ''${inputs'.wayland-mpris-idle-inhibit.packages.default}/bin/wayland-mpris-idle-inhibit --ignore "kdeconnect" --ignore "playerctld"'';
          Restart = "on-failure";
          RestartSec = "10";
        };
      };
    };

    services = {
      hyprpolkitagent.enable = true;
      kdeconnect.enable = true;
      hypridle = {
        enable = true;
        settings = {
          general = {
            lock_cmd = "pidof hyprlock || hyprlock";
            unlock_cmd = "pkill hyprlock --signal SIGUSR1";
            before_sleep_cmd = "loginctl lock-session";
            after_sleep_cmd = screenOnCmd;
          };

          listener = let
            lockTimeout = 120;
          in [
            {
              timeout = lockTimeout; # Lock the screen after 2 minutes of inactivity
              on-timeout = "loginctl lock-session";
            }
            {
              timeout = lockTimeout + 120; # Turn off the screen 2 minutes after locking
              on-timeout = screenOffCmd;
              on-resume = screenOnCmd;
            }
            {
              timeout = lockTimeout + 600; # Suspend 10 minutes after locking
              on-timeout = "systemctl suspend";
            }
          ];
        };
      };
      cliphist = {
        enable = true;
        systemdTargets = lib.mkForce [
          config.home-manager.users.bean.wayland.systemd.target
        ];
      };
      udiskie = {
        enable = true;
        automount = false;
        tray = "never";
      };
      playerctld.enable = true;
      network-manager-applet.enable = true;
      wlsunset = {
        enable = true;
        sunrise = "6:00";
        sunset = "22:00";
      };
      swayosd = {
        enable = true;
        stylePath = pkgs.writeText "swayosd-style.css" ''
          window#osd {
            border-radius: 5rem;
          }

          #container {
            padding: 5px 10px;
          }
        '';
      };
    };

    programs = {
      rofi = {
        enable = true;
        package = pkgs.rofi-wayland.override {
          plugins = with pkgs; [
            rofi-emoji-wayland
            rofi-power-menu
            rofi-bluetooth
            (rofi-calc.override {
              rofi-unwrapped = rofi-wayland-unwrapped;
            })
            rofi-pulse-select
          ];
        };
        theme = let
          inherit (config.home-manager.users.bean.lib.formats.rasi) mkLiteral;
        in {
          "@import" = "${config.catppuccin.sources.rofi}/themes/catppuccin-${config.home-manager.users.bean.catppuccin.rofi.flavor}.rasi";
          "*" =
            (builtins.mapAttrs (name: value: mkLiteral "@${value}") {
              "bg0" = "base";
              "bg1" = "mantle";
              "bg2" = "crust";
              "bg3" = config.catppuccin.accent;
              "fg0" = "subtext1";
              "fg1" = "text";
              "fg2" = "subtext0";
              "fg3" = "overlay0";
              "fg4" = "surface0";
            })
            // {
              font = mkLiteral ''"Roboto 14"'';
              background-color = mkLiteral ''transparent'';
              text-color = mkLiteral ''@fg0'';
              margin = mkLiteral ''0px'';
              padding = mkLiteral ''0px'';
              spacing = mkLiteral ''0px'';
            };
          "window" = {
            location = mkLiteral ''north'';
            y-offset = mkLiteral ''calc(50% - 176px)'';
            width = mkLiteral ''600'';
            border-radius = mkLiteral ''24px'';
            background-color = mkLiteral ''@bg0'';
          };
          "mainbox" = {
            padding = mkLiteral ''12px'';
          };
          "inputbar" = {
            background-color = mkLiteral ''@bg1'';
            border-color = mkLiteral ''@bg3'';
            border = mkLiteral ''2px'';
            border-radius = mkLiteral ''16px'';
            padding = mkLiteral ''8px 16px'';
            spacing = mkLiteral ''8px'';
            children = mkLiteral ''[ prompt, entry ]'';
          };
          "prompt" = {
            text-color = mkLiteral ''@fg2'';
          };
          "entry" = {
            placeholder = mkLiteral ''"Search"'';
            placeholder-color = mkLiteral ''@fg3'';
          };
          "message" = {
            margin = mkLiteral ''12px 0 0'';
            border-radius = mkLiteral ''16px'';
            border-color = mkLiteral ''@bg2'';
            background-color = mkLiteral ''@bg2'';
          };
          "textbox" = {
            padding = mkLiteral ''8px 24px'';
          };
          "listview" = {
            background-color = mkLiteral ''transparent'';
            margin = mkLiteral ''12px 0 0'';
            lines = mkLiteral ''8'';
            columns = mkLiteral ''2'';
            fixed-height = mkLiteral ''false'';
          };
          "element" = {
            padding = mkLiteral ''8px 16px'';
            spacing = mkLiteral ''8px'';
            border-radius = mkLiteral ''16px'';
          };
          "element normal active" = {
            text-color = mkLiteral ''@bg3'';
          };
          "element alternate active" = {
            text-color = mkLiteral ''@bg3'';
          };
          "element selected normal, element selected active" = {
            text-color = mkLiteral ''@fg4'';
            background-color = mkLiteral ''@bg3'';
          };
          "element-icon" = {
            size = mkLiteral ''1em'';
            vertical-align = mkLiteral ''0.5'';
          };
          "element-text" = {
            text-color = mkLiteral ''inherit'';
          };
        };
        location = "center";
      };
      nushell.extraConfig = ''
        plugin add ${pkgs.nu_plugin_dbus}/bin/nu_plugin_dbus
      '';
    };

    wayland.windowManager.hyprland.settings = {
      env = [
        "GRIMBLAST_EDITOR,swappy -f "
      ];

      exec-once = [
        "[workspace 3] uwsm app -- keepassxc /home/bean/Documents/Database.kdbx"
      ];

      bind = let
        powerMenu = "rofi -modi 'p:${pkgs.rofi-power-menu}/bin/rofi-power-menu' -show p --symbols-font \"FiraMono Nerd Font Mono\"";
        screenshot = "${pkgs.nushell}/bin/nu ${../../res/screenshot.nu}";
      in [
        "SUPER,S,exec,uwsm app -- rofi -show drun -icon-theme \"candy-icons\" -show-icons"
        "SUPER SHIFT,E,exec,uwsm app -- rofi -modi emoji -show emoji"
        "SUPER,Delete,exec,uwsm app -- ${powerMenu}"
        ",XF86PowerOff,exec,uwsm app -- ${powerMenu}"
        "SUPER ALT,C,exec,uwsm app -- rofi -show calc -modi calc -no-show-match -no-sort -calc-command \"echo -n '{result}' | wl-copy\""
        "SUPER,B,exec,uwsm app -- ${pkgs.rofi-bluetooth}/bin/rofi-bluetooth"
        "SUPER,Tab,exec,uwsm app -- rofi -show window -show-icons"
        "SUPER,E,exec,uwsm app -- ${pkgs.nushell}/bin/nu ${../../res/rofi/rofi-places.nu}"
        "SUPER,N,exec,uwsm app -- ${pkgs.swaynotificationcenter}/bin/swaync-client -t -sw"
        "SUPER,A,exec,uwsm app -- pavucontrol --tab 5"
        ''SUPER,V,exec,cliphist list | sed -r 's/\[\[ binary data (.* .iB) (.*) (.*) \]\]/ 󰋩 \2 Image (\3, \1)/g' | rofi -dmenu -display-columns 2 -p Clipboard | cliphist decode | wl-copy''
        "SUPER ALT,V,exec,echo -e \"Yes\\nNo\" | [[ $(rofi -dmenu -mesg \"Clear Clipboard History?\" -p Clear) == \"Yes\" ]] && cliphist wipe"
        ",Print,exec,uwsm app -- ${screenshot}"
        "SUPER SHIFT,S,exec,uwsm app -- ${screenshot}"
        "SUPER SHIFT,T,exec,${pkgs.nushell}/bin/nu ${../../res/ocr.nu}"
        "SUPER SHIFT,C,exec,uwsm app -- ${pkgs.hyprpicker}/bin/hyprpicker -a"
      ];
      bindr = [
        "SUPER SHIFT,R,exec,pkill wf-recorder --signal SIGINT || uwsm app -- ${pkgs.nushell}/bin/nu ${../../res/screenrec.nu}"
        "CAPS,Caps_Lock,exec,uwsm app -- swayosd-client --caps-lock"
        ",Scroll_Lock,exec,uwsm app -- swayosd-client --scroll-lock"
        ",Num_Lock,exec,uwsm app -- swayosd-client --num-lock"
      ];
      bindl = [
        ",switch:on:Lid Switch,exec,${screenOffCmd}"
        ",switch:off:Lid Switch,exec,${screenOnCmd}"
      ];
      bindel = [
        ",XF86MonBrightnessUp,exec,uwsm app -- swayosd-client --brightness raise"
        ",XF86MonBrightnessDown,exec,uwsm app -- swayosd-client --brightness lower"
      ];
    };
  };
}
