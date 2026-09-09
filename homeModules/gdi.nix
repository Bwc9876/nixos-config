{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  options.cow.gdi = {
    enable = lib.mkEnableOption "Niri + Customizations";
    doIdle = lib.mkEnableOption "Turn off screen, sleep, etc. from inactivity";
  };

  config = lib.mkIf config.cow.gdi.enable {
    home.packages = with pkgs; [
      alsa-utils
      dconf

      xdg-terminal-exec # For gtk-launch, etc to be able to open `Terminal` desktop entries

      ## Audio Control
      pavucontrol

      ## Image Viewer
      loupe

      ## Notifications
      libnotify

      ## Misc.
      wl-clipboard
      xdg-utils
    ];

    xdg.userDirs.setSessionVariables = true;
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = lib.mkIf config.cow.yazi.enable "yazi.desktop";
        "inode/mount-point" = lib.mkIf config.cow.yazi.enable "yazi.desktop";
      };
      # As many as possible to override system stuff
      defaultApplicationPackages =
        [pkgs.loupe]
        ++ (lib.optional config.cow.keepassxc.enable pkgs.keepassxc)
        ++ (lib.optional config.cow.qmplay2.enable pkgs.qmplay2)
        ++ (lib.optional config.cow.firefox.enable config.programs.firefox.package)
        ++ (lib.optional config.cow.alacritty.enable config.programs.alacritty.package)
        ++ (lib.optional config.cow.kitty.enable config.programs.kitty.package);
    };

    fonts.fontconfig.enable = false;

    wayland.windowManager.niri = {
      enable = true;
      settings = {
        prefer-no-csd = true;

        debug.honor-xdg-activation-with-invalid-serial = true;

        environment =
          {
            NIXOS_OZONE_WL = "1";
          }
          // (builtins.mapAttrs (_: v: builtins.toString v) config.home.sessionVariables); # TODO: Hack?

        _children = [
          {
            window-rule = {
              geometry-corner-radius = 10.0;
              clip-to-geometry = true;
            };
          }
          {
            window-rule = {
              match._props.is-window-cast-target = true;

              focus-ring = {
                active-color = "#f38ba8";
                inactive-color = "#7d0d2d";
              };

              border.inactive-color = "#7d0d2d";
              shadow.color = "#7d0d2d70";
            };
          }
        ];

        hotkey-overlay = {
          hide-not-bound = true;
          skip-at-startup = true;
        };

        clipboard.disable-primary = true;

        input = {
          focus-follows-mouse._props.max-scroll-amount = "10%";
          keyboard.numlock = true;
          touchpad = {
            natural-scroll = {};
            tap = {};
          };
        };

        layout = {
          # gaps = 4;
          # center-focused-column = "on-overflow";
          struts = let
            val = -4;
          in {
            top = val;
            bottom = val;
            left = val;
            right = val;
          };
          default-column-width.proportion = 0.45;
          focus-ring.width = 2;
          focus-ring.active-gradient._props = {
            "in" = "oklch longer hue";
            angle = 135;
            relative-to = "workspace-view";
            from = "#0f08";
            to = "#f007";
          };
        };

        binds = let
          emptyBind = name: {${name} = {};};
          spawnPkg = p: args: {spawn = [(lib.getExe p)] ++ args;};
          move-column-to-workspace = n: {move-column-to-workspace = [n];};
          focus-workspace = n: {focus-workspace = [n];};
          spawnSh = c: {spawn = ["sh" "-c" c];};
          spawnPlayerctl = act: spawnPkg pkgs.playerctl [act];
          allowLocked = act: act // {_props.allow-when-locked = true;};
          spawnNoct = args: spawnPkg pkgs.noctalia args;
          volume = act: spawnNoct ["msg" "volume-${act}"];
          brightness = act: spawnNoct ["msg" "brightness-${act}"];
          launchDesktop = name: {spawn = ["${pkgs.gtk3}/bin/gtk-launch" "${name}.desktop"];};
        in {
          # Niri Stuff

          ## Basics
          "Mod+X" = emptyBind "quit";
          "Mod+Tab" = emptyBind "toggle-overview";
          "Mod+Slash" = emptyBind "show-hotkey-overlay";
          "Mod+C" = emptyBind "close-window";

          "Mod+Left" = emptyBind "focus-column-left";
          "Mod+Down" = emptyBind "focus-window-down";
          "Mod+Up" = emptyBind "focus-window-up";
          "Mod+Right" = emptyBind "focus-column-right";

          "Mod+Shift+Left" = emptyBind "move-column-left";
          "Mod+Shift+Down" = emptyBind "move-window-down";
          "Mod+Shift+Up" = emptyBind "move-window-up";
          "Mod+Shift+Right" = emptyBind "move-column-right";

          "Mod+Home" = emptyBind "focus-column-first";
          "Mod+End" = emptyBind "focus-column-last";
          "Mod+Shift+Home" = emptyBind "move-column-to-first";
          "Mod+Shift+End" = emptyBind "move-column-to-last";

          "Mod+BracketLeft" = emptyBind "consume-or-expel-window-left";
          "Mod+BracketRight" = emptyBind "consume-or-expel-window-right";

          "Mod+Comma".set-column-width = "-100";
          "Mod+Shift+Comma".set-column-width = "-20";
          "Mod+Period".set-column-width = "+100";
          "Mod+Shift+Period".set-column-width = "+20";

          "Mod+F" = emptyBind "maximize-column";
          "Mod+Shift+F" = emptyBind "fullscreen-window";
          "Mod+Ctrl+F" = emptyBind "expand-column-to-available-width";
          "Mod+Ctrl+Shift+F" = emptyBind "toggle-windowed-fullscreen";

          "Mod+Page_Down" = emptyBind "focus-workspace-down";
          "Mod+Page_Up" = emptyBind "focus-workspace-up";
          "Mod+U" = emptyBind "focus-workspace-down";
          "Mod+I" = emptyBind "focus-workspace-up";
          "Mod+Shift+Page_Down" = emptyBind "move-column-to-workspace-down";
          "Mod+Shift+Page_Up" = emptyBind "move-column-to-workspace-up";
          "Mod+Shift+U" = emptyBind "move-column-to-workspace-down";
          "Mod+Shift+I" = emptyBind "move-column-to-workspace-up";

          "Mod+1" = focus-workspace 1;
          "Mod+2" = focus-workspace 2;
          "Mod+3" = focus-workspace 3;
          "Mod+4" = focus-workspace 4;
          "Mod+5" = focus-workspace 5;
          "Mod+6" = focus-workspace 6;
          "Mod+7" = focus-workspace 7;
          "Mod+8" = focus-workspace 8;
          "Mod+9" = focus-workspace 9;
          "Mod+Ctrl+1" = move-column-to-workspace 1;
          "Mod+Ctrl+2" = move-column-to-workspace 2;
          "Mod+Ctrl+3" = move-column-to-workspace 3;
          "Mod+Ctrl+4" = move-column-to-workspace 4;
          "Mod+Ctrl+5" = move-column-to-workspace 5;
          "Mod+Ctrl+6" = move-column-to-workspace 6;
          "Mod+Ctrl+7" = move-column-to-workspace 7;
          "Mod+Ctrl+8" = move-column-to-workspace 8;
          "Mod+Ctrl+9" = move-column-to-workspace 9;

          "Mod+Escape" =
            emptyBind "toggle-keyboard-shortcuts-inhibit"
            // {
              _props.allow-inhibiting = false;
            };

          "Mod+Z".spawn = ["systemctl" "suspend"];
          "Super+Alt+Ctrl+Shift+L".spawn = ["xdg-open" "https://linkedin.com"];

          # Noctalia
          "Mod+S" = spawnNoct ["msg" "panel-toggle" "launcher"];

          # Terminal
          "Mod+T" = spawnSh "exec $TERMINAL";

          # Yazi
          "Mod+E" = lib.mkIf config.cow.yazi.enable (launchDesktop "yazi");

          "Mod+Shift+S" = spawnNoct ["msg" "screenshot-annotate"];
          "Mod+Shift+R" = spawnNoct ["msg" "plugin" "noctalia/screen_recorder:service" "all" "toggle"];
          "Mod+Shift+C" = spawnNoct ["msg" "plugin" "oldirtty/color_picker:service" "all" "pick"];
          "Mod+P" = spawnNoct ["msg" "panel-toggle" "elijaharch/wl-screen-mirror:controls"];
          "Mod+L".spawn = ["loginctl" "lock-session"];
          "Mod+V" = spawnNoct ["msg" "panel-open" "clipboard"];

          # Volume
          "XF86AudioRaiseVolume" = volume "up";
          "XF86AudioLowerVolume" = volume "down";
          "XF86AudioMute" = volume "mute";

          # Brightness
          "XF86MonBrightnessUp" = brightness "up";
          "XF86MonBrightnessDown" = brightness "down";

          # Playerctl
          "XF86AudioPlay" = spawnPlayerctl "play-pause";
          "XF86AudioPause" = spawnPlayerctl "pause";
          "XF86AudioStop" = spawnPlayerctl "stop";
          "XF86AudioNext" = spawnPlayerctl "next";
          "XF86AudioPrev" = spawnPlayerctl "previous";

          # Firefox
          "Mod+Q" = lib.mkIf config.cow.firefox.enable (launchDesktop "firefox-devedition");
        };
      };
    };

    services.wayland-mpris-idle-inhibit = lib.mkIf config.cow.gdi.doIdle {
      enable = true;
      ignorePlayers = ["kdeconnect" "playerctld"];
    };

    qt = {
      enable = true;
      platformTheme.name = "kvantum";
      style.name = "kvantum";
    };

    catppuccin.cursors = {
      enable = true;
      accent = "dark";
    };
    home.pointerCursor.enable = true;

    gtk = {
      enable = true;
      gtk2.extraConfig = "gtk-application-prefer-dark-theme=true";
      gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
      gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
      gtk4.theme = config.gtk.theme;
    };

    dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";

    services = {
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
    };

    programs = {
      nushell.extraConfig = ''
        plugin add ${inputs.nu_plugin_dbus.packages.${pkgs.system}.default}/bin/nu_plugin_dbus
      '';
    };
  };
}
