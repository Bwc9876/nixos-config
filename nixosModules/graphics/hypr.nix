{pkgs, ...}: {
  environment = {
    systemPackages = with pkgs; [
      hyprpicker
      uwsm
    ];
  };

  xdg.portal.extraPortals = with pkgs; [xdg-desktop-portal-gtk];

  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  home-manager.users.bean = {
    wayland.windowManager.hyprland = {
      systemd.enable = false;
      enable = true;
      extraConfig = ''
        bind = SUPER,M,submap,passthru
        submap = passthru
        bind = SUPER,ESCAPE,submap,reset
        submap = reset
      '';
      settings = {
        autogenerated = 0;
        monitor = [
          "eDP-1,2256x1504,0x0,1"
          ",highres,auto,1"
        ];
        general = {
          border_size = 2;
          resize_on_border = true;
          "col.active_border" = let
            red = "rgb(f38ba8)";
            peach = "rgb(fab387)";
            yellow = "rgb(f9e2af)";
            green = "rgb(a6e3a1)";
            sapphire = "rgb(74c7ec)";
            lavender = "rgb(b4befe)";
            mauve = "rgb(cba6f7)";
          in "${red} ${peach} ${yellow} ${green} ${sapphire} ${lavender} ${mauve} 225deg";
        };
        decoration = {
          rounding = 10;
        };
        input = {
          numlock_by_default = true;
          kb_options = "caps:escape";
          touchpad = {
            natural_scroll = true;
          };
        };
        gestures = {
          workspace_swipe = true;
        };
        xwayland = {
          force_zero_scaling = true;
        };
        # debug = {
        #   disable_logs = false;
        # };
        misc = {
          enable_swallow = true;
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          focus_on_activate = true;
          mouse_move_enables_dpms = true;
          key_press_enables_dpms = true;
        };
        env = [
          "TERMINAL,kitty"
        ];
        windowrulev2 = [
          "workspace 1 silent,class:(.*)vesktop(.*),title:(.*)[Vv]esktop(.*)"
          "idleinhibit fullscreen,class:(.*),title:(.*)"
        ];
        submap = "reset";
        bind = let
          openTerminal = "uwsm app -- kitty.desktop";
          forEachWorkspace = {
            mod,
            dispatch,
          }:
            builtins.genList
            (i: let
              num = builtins.toString i;
            in "${mod},${num},${dispatch},${
              if num == "0"
              then "10"
              else num
            }")
            10;
        in
          [
            "SUPER,M,submap,passthru"
            "SUPER,Q,exec,uwsm app -- firefox-devedition.desktop"
            "SUPER,Z,exec,systemctl suspend"
            ",XF86AudioMedia,exec,${openTerminal}"
            "SUPER,T,exec,${openTerminal}"
            "SUPER ALT CTRL SHIFT,L,exec,xdg-open https://linkedin.com"
            "SUPER,C,killactive,"
            "SUPER,P,pseudo,"
            "SUPER,R,togglefloating,"
            "SUPER,F,fullscreen,1"
            "SUPER SHIFT,F,fullscreen,0"
            "SUPER,J,togglesplit,"
            "SUPER,left,movefocus,l"
            "SUPER,right,movefocus,r"
            "SUPER,up,movefocus,u"
            "SUPER,down,movefocus,d"
            "SUPER,G,togglegroup"
            "SUPER SHIFT,G,lockactivegroup, toggle"
            "SUPER,TAB,changegroupactive"
            "SUPER SHIFT,TAB,changegroupactive,b"
            ",XF86RFKill,exec,rfkill toggle wifi"
          ]
          ++ forEachWorkspace {
            mod = "SUPER";
            dispatch = "workspace";
          }
          ++ forEachWorkspace {
            mod = "SUPER SHIFT";
            dispatch = "movetoworkspace";
          };
        bindm = [
          "SUPER,mouse:272,movewindow"
          "SUPER,mouse:273,resizewindow"
        ];
      };
    };
  };
}
