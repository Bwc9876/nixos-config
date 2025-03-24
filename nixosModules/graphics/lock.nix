{pkgs, ...}: {
  home-manager.users.bean = {
    catppuccin.hyprlock.useDefaultConfig = false;
    wayland.windowManager.hyprland.settings = {
      bind = [
        "SUPER,L,exec,pidof hyprlock || hyprlock --immediate"
      ];
    };

    programs.hyprlock = {
      enable = true;

      settings = {
        general.grace = 5;
        background = {
          monitor = "";
          path = "${../../res/pictures/background.png}";
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
          path = "${../../res/pictures/cow.png}";
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
            text = ''cmd[update:30000] echo "  $(date +"%A, %B %-d | %I:%M %p") | $(${pkgs.nushell}/bin/nu ${../../res/bat_display.nu})  "'';
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
  };
}
