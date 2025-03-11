{
  pkgs,
  config,
  lib,
  ...
}: {
  users.users.bean.extraGroups = ["video"];

  environment.systemPackages = with pkgs; [
    # Shell Components
    hyprlock
    hypridle
    hyprpolkitagent
    hyprland-qtutils
    swaynotificationcenter
    swayosd

    ## Waybar
    waybar
    qt6.qttools # For component

    libsForQt5.dolphin
    libsForQt5.ark # For archive support
    libsForQt5.kio-extras # For thumbnails
    libsForQt5.kdegraphics-thumbnailers # For thumbnails

    networkmanagerapplet
    pavucontrol
    udiskie

    wf-recorder
    slurp
    grim
    xdg-utils
    grimblast
    tesseract
    swappy
    libnotify

    keepassxc

    plasma5Packages.kdeconnect-kde

    hunspell
    hunspellDicts.en_US
    hunspellDicts.en_US-large

    (callPackage wl-clipboard.overrideAttrs {
      src = fetchFromGitHub {
        owner = "Bwc9876";
        repo = "wl-clipboard";
        rev = "bwc9876/x-kde-passwordManagerHint-sensitive";
        sha256 = "sha256-DD0efaKaqAMqp4KwQPwuKlNtGuHIXvfE0SBfTKSADOM=";
      };
    })
    (callPackage cliphist.overrideAttrs {
      src = fetchFromGitHub {
        owner = "sentriz";
        repo = "cliphist";
        rev = "8c48df70bb3d9d04ae8691513e81293ed296231a";
        sha256 = "sha256-tImRbWjYCdIY8wVMibc5g5/qYZGwgT9pl4pWvY7BDlI=";
      };
      vendorHash = "sha256-gG8v3JFncadfCEUa7iR6Sw8nifFNTciDaeBszOlGntU=";
    })
  ];

  services.udisks2.enable = true;

  home-manager.users.bean = {
    xdg.configFile = {
      dolphinrc.source = "${../../res/theming/dolphinrc}";
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
      "swayosd/style.css".text = ''
        window#osd {
          border-radius: 5rem;
        }

        #container {
          padding: 5px 10px;
        }
      '';

      "kdeconnect/config".text = ''
        [General]
        name=${lib.toUpper config.networking.hostName}
      '';
    };

    # Doing our own thing for rofi
    catppuccin.rofi.enable = false;

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
      exec-once = [
        "systemctl --user start hyprpolkitagent"
        "hypridle"
        "uwsm app -- dolphin --daemon"
        "uwsm app -- waybar"
        "wl-paste --watch bash ${../../res/clipboard_middleman.sh}"
        "uwsm app -- swaync"
        "uwsm app -- swayosd-server"
        "uwsm app -- nm-applet"
        "${pkgs.udiskie}/bin/udiskie -A -f dolphin"
        "${pkgs.nushell}/bin/nu ${../../res/battery_notif.nu}"
        "playerctld"
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
      bindel = [
        ",XF86MonBrightnessUp,exec,uwsm app -- swayosd-client --brightness raise"
        ",XF86MonBrightnessDown,exec,uwsm app -- swayosd-client --brightness lower"
      ];
    };
  };
}
