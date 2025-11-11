{ inputs, ... }:
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [ inputs.niri.homeModules.niri ];

  # TODO: Replace Hyprland with Niri, switch out gdi.nix for this
  options.cow.gdi = {
    enable = lib.mkEnableOption "Niri + Customizations";
    doIdle = lib.mkEnableOption "Turn off screen, sleep, etc. from inactivity";
  };

  config =
    let
      iconTheme = {
        name = "Tela-green";
        package = pkgs.tela-icon-theme;
      };
      cursorTheme = {
        name = "catppuccin-mocha-dark-cursors";
        package = pkgs.catppuccin-cursors.mochaDark;
        size = 24;
      };
    in
    lib.mkIf config.cow.gdi.enable {
      nixpkgs.overlays = [ inputs.niri.overlays.niri ];

      # Me when I'm stupid and enable my preferred keyring unconditionally in a flake for a WM
      services.gnome-keyring.enable = lib.mkForce false;

      home.packages = with pkgs; [
        alsa-utils

        cursorTheme.package
        iconTheme.package

        wezterm

        # Shell Components
        hyprlock

        ## Waybar
        qt6.qttools # For component

        pavucontrol

        wf-recorder
        slurp
        grim
        xdg-utils
        grimblast
        swappy
        libnotify
        swaynotificationcenter
        wl-clipboard

        hunspell
        hunspellDicts.en_US-large
      ];

      xdg.mimeApps = lib.mkDefault {
        enable = true;
        defaultApplications = {
          "application/pdf" = lib.mkIf config.cow.firefox.enable "firefox-devedition.desktop";
          "image/*" = lib.mkIf config.cow.firefox.enable "firefox-devedition.desktop";
          "text/*" = lib.mkIf config.cow.neovim.enable "neovide.desktop";
          "inode/directory" = lib.mkIf config.cow.yazi.enable "yazi.desktop";
          "inode/mount-point" = lib.mkIf config.cow.yazi.enable "yazi.desktop";
        };
      };

      fonts.fontconfig.enable = false;

      programs.niri = {
        enable = true;
        settings = {
          prefer-no-csd = true;

          environment = {
            NIXOS_OZONE_WL = "1";
          };

          screenshot-path = "~/Pictures/Screenshots/%Y%m%d_%H%M%S.png";

          xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite-unstable;

          window-rules = [
            {
              geometry-corner-radius =
                let
                  s = 10.0;
                in
                {
                  top-left = s;
                  top-right = s;
                  bottom-left = s;
                  bottom-right = s;
                };
              clip-to-geometry = true;
            }
          ];

          hotkey-overlay = {
            hide-not-bound = true;
            skip-at-startup = true;
          };

          clipboard.disable-primary = true;

          input = {
            focus-follows-mouse.enable = true;
            keyboard.numlock = true;
            # power-key-handling.enable = false;
            touchpad.natural-scroll = true;
          };

          layout = {
            default-column-width.proportion = 1.;
            focus-ring.active.gradient = {
              in' = "oklab";
              angle = 135;
              relative-to = "workspace-view";
              from = "#74c7ec";
              to = "#cba6f7";
            };
          };

          binds =
            with config.lib.niri.actions;
            let
              spawnPkg = p: spawn "${lib.getExe p}";
              move-column-to-workspace = n: { move-column-to-workspace = [ n ]; };
              terminal = pkgs.wezterm;
              spawnTerm = spawnPkg terminal;
              spawnNu = spawnPkg pkgs.nushell;
              spawnPlayerctl = spawnPkg pkgs.playerctl;
              spawnRofi = spawn "rofi";
              spawnSh = spawn "sh" "-c";
              spawnOsd = spawn "${pkgs.swayosd}/bin/swayosd-client";
              launchDesktop = x: spawn "${pkgs.gtk3}/bin/gtk-launch" "${x}.desktop";
              brightness = spawnOsd "--brightness";
              volume = spawnOsd "--output-volume";
            in
            {
              # Niri Stuff

              ## Basics
              "Mod+X".action = quit;
              "Mod+Tab".action = toggle-overview;
              "Mod+Slash".action = show-hotkey-overlay;
              "Mod+C".action = close-window;

              "Mod+Left".action = focus-column-left;
              "Mod+Down".action = focus-window-down;
              "Mod+Up".action = focus-window-up;
              "Mod+Right".action = focus-column-right;

              "Mod+Shift+Left".action = move-column-left;
              "Mod+Shift+Down".action = move-window-down;
              "Mod+Shift+Up".action = move-window-up;
              "Mod+Shift+Right".action = move-column-right;

              "Mod+Home".action = focus-column-first;
              "Mod+End".action = focus-column-last;
              "Mod+Shift+Home".action = move-column-to-first;
              "Mod+Shift+End".action = move-column-to-last;

              "Mod+BracketLeft".action = consume-or-expel-window-left;
              "Mod+BracketRight".action = consume-or-expel-window-right;

              "Mod+F".action = maximize-column;
              "Mod+Shift+F".action = fullscreen-window;
              "Mod+Ctrl+F".action = expand-column-to-available-width;
              "Mod+Ctrl+Shift+F".action = toggle-windowed-fullscreen;

              "Mod+Page_Down".action = focus-workspace-down;
              "Mod+Page_Up".action = focus-workspace-up;
              "Mod+U".action = focus-workspace-down;
              "Mod+I".action = focus-workspace-up;
              "Mod+Shift+Page_Down".action = move-column-to-workspace-down;
              "Mod+Shift+Page_Up".action = move-column-to-workspace-up;
              "Mod+Shift+U".action = move-column-to-workspace-down;
              "Mod+Shift+I".action = move-column-to-workspace-up;

              "Mod+1".action = focus-workspace 1;
              "Mod+2".action = focus-workspace 2;
              "Mod+3".action = focus-workspace 3;
              "Mod+4".action = focus-workspace 4;
              "Mod+5".action = focus-workspace 5;
              "Mod+6".action = focus-workspace 6;
              "Mod+7".action = focus-workspace 7;
              "Mod+8".action = focus-workspace 8;
              "Mod+9".action = focus-workspace 9;
              "Mod+Ctrl+1".action = move-column-to-workspace 1;
              "Mod+Ctrl+2".action = move-column-to-workspace 2;
              "Mod+Ctrl+3".action = move-column-to-workspace 3;
              "Mod+Ctrl+4".action = move-column-to-workspace 4;
              "Mod+Ctrl+5".action = move-column-to-workspace 5;
              "Mod+Ctrl+6".action = move-column-to-workspace 6;
              "Mod+Ctrl+7".action = move-column-to-workspace 7;
              "Mod+Ctrl+8".action = move-column-to-workspace 8;
              "Mod+Ctrl+9".action = move-column-to-workspace 9;

              "Mod+Escape" = {
                action = toggle-keyboard-shortcuts-inhibit;
                allow-inhibiting = false;
              };

              "Mod+Shift+S".action = {
                screenshot = [ ];
              };
              "Print".action = {
                screenshot = [ ];
              };
              "Mod+L".action = spawnSh "pidof hyprlock || hyprlock --immediate";
              "Mod+Z".action = spawn "systemctl" "suspend";
              "Super+Alt+Ctrl+Shift+L".action = spawn "xdg-open" "https://linkedin.com";

              # Terminal
              "Mod+T".action = spawnTerm;

              # Rofi
              "Mod+S".action = spawnRofi "-show" "drun" "-show-icons";
              "Mod+B".action = spawnPkg pkgs.rofi-bluetooth;
              "Mod+Shift+E".action = spawnRofi "-modi" "emoji" "-show" "emoji";
              "Mod+Alt+C".action =
                spawnRofi "-show" "calc" "-modi" "calc" "-no-show-match" "-no-sort" "-calc-command"
                  "echo -n '{result}' | wl-copy";
              "Mod+V".action =
                spawnSh "cliphist list | sed -r 's/\[\[ binary data (.* .iB) (.*) (.*) \]\]/ 󰋩 \2 Image (\3, \1)/g' | rofi -dmenu -display-columns 2 -p Clipboard | cliphist decode | wl-copy";
              "Mod+Alt+V".action =
                spawnSh "echo -e \"Yes\\nNo\" | [[ $(rofi -dmenu -mesg \"Clear Clipboard History?\" -p Clear) == \"Yes\" ]] && cliphist wipe";

              # Yazi
              "Mod+E".action = lib.mkIf config.cow.yazi.enable (launchDesktop "yazi");

              # Firefox
              "Mod+Q".action = lib.mkIf config.cow.firefox.enable (launchDesktop "firefox-devedition");

              # Pavucontrol
              "Mod+A".action = spawnPkg pkgs.pavucontrol "--tab" "5";

              # Brightness
              "XF86MonBrightnessUp" = {
                action = brightness "raise";
                allow-when-locked = true;
              };
              "XF86MonBrightnessDown" = {
                action = brightness "lower";
                allow-when-locked = true;
              };

              # Volume
              "XF86AudioRaiseVolume" = {
                action = volume "raise";
                allow-when-locked = true;
              };
              "XF86AudioLowerVolume" = {
                action = volume "lower";
                allow-when-locked = true;
              };
              "XF86AudioMute" = {
                action = volume "mute-toggle";
                allow-when-locked = true;
              };

              # Playerctl
              "XF86AudioPlay" = {
                action = spawnPlayerctl "play-pause";
                allow-when-locked = true;
              };
              "XF86AudioPause" = {
                action = spawnPlayerctl "pause";
                allow-when-locked = true;
              };
              "XF86AudioStop" = {
                action = spawnPlayerctl "stop";
                allow-when-locked = true;
              };
              "XF86AudioNext" = {
                action = spawnPlayerctl "next";
                allow-when-locked = true;
              };
              "XF86AudioPrev" = {
                action = spawnPlayerctl "previous";
                allow-when-locked = true;
              };
            };
        };
      };

      catppuccin.hyprlock.useDefaultConfig = false;
      programs.hyprlock = {
        enable = true;

        settings = {
          background = {
            monitor = "";
            path = "${config.cow.pictures.bg}";
            blur_passes = 1;
          };
          shape = [
            {
              monitor = "";
              color = "$crust";
              position = "0, 30";
              rounding = 10;
              border_size = 2;
              border_color = "$mauve";
              size = "500, 500";
              shadow_passes = 1;
              shadow_size = 2;
            }
            {
              monitor = "";
              color = "$crust";
              position = "0, -30";
              rounding = 10;
              border_size = 2;
              border_color = "$mauve";
              size = "600, 50";
              valign = "top";
              shadow_passes = 1;
              shadow_size = 2;
            }
          ];
          image = {
            monitor = "";
            path = "${config.cow.pictures.pfp}";
            size = 150;
            rounding = -1;
            border_size = 4;
            border_color = "$mauve";
            rotate = 0;
            position = "0, 120";
            halign = "center";
            valign = "center";
          };
          "input-field" = {
            monitor = "";
            size = "250, 50";
            outline_thickness = 2;
            dots_size = 0.25; # Scale of input-field height, 0.2 - 0.8
            dots_spacing = 0.15; # Scale of dots' absolute size, 0.0 - 1.0
            dots_center = false;
            dots_rounding = -1; # -1 default circle, -2 follow input-field rounding
            outer_color = "$surface0";
            inner_color = "$base";
            font_color = "$text";
            fade_on_empty = false;
            fade_timeout = 1000; # Milliseconds before fade_on_empty is triggered.
            placeholder_text = ''<span foreground="##cdd6f4" style="italic">Password</span>'';
            hide_input = false;
            rounding = -1; # -1 means complete rounding (circle/oval)
            check_color = "$peach";
            fail_color = "$red"; # if authentication failed, changes outer_color and fail message color
            fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
            fail_transition = 300; # transition time in ms between normal outer_color and fail_color
            capslock_color = -1;
            numlock_color = -1;
            bothlock_color = -1; # when both locks are active. -1 means don't change outer color (same for above)
            invert_numlock = false; # change color if numlock is off
            swap_font_color = false; # see below

            position = "0, -80";
            halign = "center";
            valign = "center";
          };
          label = [
            {
              monitor = "";
              text = "$DESC";
              color = "$text";
              font_size = 25;
              font_family = "sans-serif";
              rotate = 0; # degrees, counter-clockwise

              position = "0, 0";
              halign = "center";
              valign = "center";
            }
            {
              monitor = "";
              text = ''cmd[update:30000] echo "  $(date +"%A, %B %-d | %I:%M %p")$(${pkgs.nushell}/bin/nu ${../res/bat_display.nu})  "'';
              color = "$text";
              font_size = 20;
              font_family = "sans-serif";
              rotate = 0; # degrees, counter-clockwise

              position = "0, -40";
              halign = "center";
              valign = "top";
            }
          ];
        };
      };

      catppuccin.rofi.enable = false;

      systemd.user.services =
        let
          target = config.wayland.systemd.target;
          mkShellService =
            {
              desc,
              service,
            }:
            {
              Install = {
                WantedBy = [ target ];
              };

              Unit = {
                ConditionEnvironment = "WAYLAND_DISPLAY";
                Description = desc;
                After = [ target ];
                PartOf = [ target ];
              };

              Service = service;
            };
        in
        {
          battery-notif = mkShellService {
            desc = "Battery Notification Service";

            service = {
              ExecStart = "${pkgs.nushell}/bin/nu --plugins ${
                inputs.nu_plugin_dbus.packages.${pkgs.system}.default
              } ${../res/battery_notif.nu}";
              Restart = "on-failure";
              RestartSec = "10";
            };
          };

          swaybg = lib.mkIf config.cow.pictures.enable (mkShellService {
            desc = "Sway Background Image";
            service = {
              ExecStart = "${lib.getExe pkgs.swaybg} --image ${config.cow.pictures.bg}";
              Restart = "on-failure";
              RestartSec = "10";
            };
          });

          mpris-idle-inhibit = mkShellService {
            desc = "MPRIS Idle Inhibitor";

            service = {
              ExecStart = ''${
                inputs.wayland-mpris-idle-inhibit.packages.${pkgs.system}.default
              }/bin/wayland-mpris-idle-inhibit --ignore "kdeconnect" --ignore "playerctld"'';
              Restart = "on-failure";
              RestartSec = "10";
            };
          };
        };

      qt = {
        enable = true;
        platformTheme.name = "kvantum";
        style.name = "kvantum";
      };

      home.pointerCursor = {
        inherit (cursorTheme) name package size;
        enable = true;
        gtk.enable = true;
        x11.enable = true;
      };

      gtk = {
        enable = true;
        iconTheme = lib.mkForce iconTheme;
        gtk2.extraConfig = "gtk-application-prefer-dark-theme=true";
        gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
        gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
      };

      dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

      services = {
        swaync = {
          enable = true;
          settings = {
            control-center-exclusive-zone = false;
            control-center-height = 1000;
            control-center-margin-bottom = 10;
            control-center-margin-left = 10;
            control-center-margin-right = 10;
            control-center-margin-top = 0;
            control-center-width = 800;
            fit-to-screen = false;
            hide-on-action = true;
            hide-on-clear = false;
            image-visibility = "when-available";
            keyboard-shortcuts = true;
            notification-body-image-height = 100;
            notification-body-image-width = 200;
            notification-icon-size = 64;
            notification-window-width = 500;
            positionX = "center";
            positionY = "top";
            script-fail-notify = true;
            scripts = {
              all = {
                exec = "${pkgs.nushell}/bin/nu ${../res/notification.nu} ${../res/notif-sounds}";
                urgency = ".*";
              };
            };
            timeout = 10;
            timeout-critical = 0;
            timeout-low = 5;
            transition-time = 200;
            widget-config = {
              dnd = {
                text = "Do Not Disturb";
              };
              label = {
                max-lines = 1;
                text = "Notification Center";
              };
              title = {
                button-text = "Clear All";
                clear-all-button = true;
                text = "Notification Center";
              };
            };
            widgets = [
              "title"
              "dnd"
              "notifications"
            ];
          };
        };

        swayidle =
          let
            lockCmd = args: "pidof hyprlock || ${lib.getExe pkgs.hyprlock} ${args}";
          in
          lib.mkIf config.cow.gdi.doIdle {
            enable = false;
            timeouts = [
              {
                timeout = 10;
                command = lockCmd "--grace 5";
              }
              {
                timeout = 30;
                command = "${pkgs.systemd}/bin/systemctl suspend";
              }
            ];
            events = [
              {
                event = "before-sleep";
                command = lockCmd "--immediate";
              }
            ];
          };

        cliphist = {
          enable = true;
          systemdTargets = lib.mkForce [
            config.wayland.systemd.target
          ];
        };
        udiskie = {
          enable = true;
          automount = false;
          tray = "never";
        };
        playerctld.enable = true;
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
          package = pkgs.rofi.override {
            plugins = with pkgs; [
              rofi-emoji
              rofi-power-menu
              rofi-bluetooth
              rofi-calc
              rofi-pulse-select
            ];
          };
          theme =
            let
              inherit (config.lib.formats.rasi) mkLiteral;
            in
            {
              "@import" =
                "${config.catppuccin.sources.rofi}/themes/catppuccin-${config.catppuccin.rofi.flavor}.rasi";
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
          plugin add ${inputs.nu_plugin_dbus.packages.${pkgs.system}.default}/bin/nu_plugin_dbus
        '';

        wezterm = {
          enable = true;
          extraConfig = ''
            return {
              font = wezterm.font("monospace"),
              font_size = 18.0,
              color_scheme = "Catppuccin Mocha",
              enable_tab_bar = false,
              window_background_opacity = 0.92,
              default_cursor_style = "SteadyBar",
              cursor_thickness = 2,
              keys = {
                {key="o", mods="CTRL|SHIFT", action="OpenLinkAtMouseCursor"}
              }
            }
          '';
        };
      };
    };
}
