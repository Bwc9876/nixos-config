{
  pkgs,
  inputs,
  config,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # Shell Components
    hyprlock
    hypridle
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
      dolphinrc.source = "${inputs.self}/res/theming/dolphinrc";
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
        location = "center";
      };
    };

    wayland.windowManager.hyprland.settings = {
      exec-once = [
        "hypridle"
        "dolphin --daemon"
        "waybar"
        "wl-paste --watch bash ${inputs.self}/res/clipboard_middleman.sh"
        "swaync"
        "swayosd-server"
        "nm-applet"
        "${pkgs.udiskie}/bin/udiskie -A -f dolphin"
        "${pkgs.nushell}/bin/nu ${inputs.self}/res/battery_notif.nu"
        "playerctld"
        "[workspace 3] keepassxc /home/bean/Documents/Database.kdbx"
      ];

      bind = let
        powerMenu = "rofi -modi 'p:${pkgs.rofi-power-menu}/bin/rofi-power-menu' -show p --symbols-font \"FiraMono Nerd Font Mono\"";
        screenshot = "${pkgs.nushell}/bin/nu ${inputs.self}/res/screenshot.nu";
      in [
        "SUPER,S,exec,rofi -show drun -icon-theme \"candy-icons\" -show-icons"
        "SUPER SHIFT,E,exec,rofi -modi emoji -show emoji"
        "SUPER,Delete,exec,${powerMenu}"
        ",XF86PowerOff,exec,${powerMenu}"
        "SUPER ALT,C,exec,rofi -show calc -modi calc -no-show-match -no-sort -calc-command \"echo -n '{result}' | wl-copy\""
        "SUPER,I,exec,${pkgs.rofi-pulse-select}/bin/rofi-pulse-select source"
        "SUPER,O,exec,${pkgs.rofi-pulse-select}/bin/rofi-pulse-select sink"
        "SUPER,B,exec,${pkgs.rofi-bluetooth}/bin/rofi-bluetooth"
        "SUPER,Tab,exec,rofi -show window -show-icons"
        "SUPER,E,exec,${pkgs.nushell}/bin/nu ${inputs.self}/res/rofi/rofi-places.nu"
        "SUPER SHIFT,T,exec,${pkgs.nushell}/bin/nu ${inputs.self}/res/rofi/rofi-zoxide.nu"
        "SUPER,N,exec,${pkgs.swaynotificationcenter}/bin/swaync-client -t -sw"
        "SUPER,A,exec,pavucontrol --tab 5"
        "SUPER,V,exec,cliphist list | sed -r \"s|binary data image/(.*)|󰋩 Image (\\1)|g\" | rofi -dmenu -display-columns 2 -p Clipboard | cliphist decode | wl-copy"
        "SUPER ALT,V,exec,echo -e \"Yes\\nNo\" | [[ $(rofi -dmenu -mesg \"Clear Clipboard History?\" -p Clear) == \"Yes\" ]] && cliphist wipe"
        ",Print,exec,${screenshot}"
        "SUPER SHIFT,S,exec,${screenshot}"
        "SUPER SHIFT,C,exec,${pkgs.hyprpicker}/bin/hyprpicker -a"
      ];
      bindr = [
        "SUPER SHIFT,R,exec,pkill wf-recorder --signal SIGINT || nu ${inputs.self}/res/screenrec.nu"
        "CAPS,Caps_Lock,exec,swayosd-client --caps-lock"
        ",Scroll_Lock,exec,swayosd-client --scroll-lock"
        ",Num_Lock,exec,swayosd-client --num-lock"
      ];
      bindel = [
        ",XF86MonBrightnessUp,exec,swayosd-client --brightness raise"
        ",XF86MonBrightnessDown,exec,swayosd-client --brightness lower"
      ];
    };
  };
}
