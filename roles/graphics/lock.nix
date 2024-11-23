{
  pkgs,
  inputs,
  ...
}: {
  home-manager.users.bean = {
    wayland.windowManager.hyprland.settings = {
      bind = [
        "SUPER,L,exec,pidof hyprlock || hyprlock --immediate"
      ];
    };

    xdg.configFile."hypr/hyprlock.conf".text = ''
      general {
          grace = 5
      }

      background {
          monitor =
          path = "${inputs.self}/res/pictures/background.png"
          blur_passes = 1
      }

      image {
          monitor =
          path = "${inputs.self}/res/pictures/cow.png"
          size = 150
          rounding = -1
          border_size = 2
          border_color = rgb(109, 237, 153)
          rotate = 0
          position = 0, 120
          halign = center
          valign = center

          shadow_passes = 1
          shadow_size = 5
          shadow_boost = 1.6
      }

      input-field {
          monitor =
          size = 250, 50
          outline_thickness = 2
          dots_size = 0.25 # Scale of input-field height, 0.2 - 0.8
          dots_spacing = 0.15 # Scale of dots' absolute size, 0.0 - 1.0
          dots_center = false
          dots_rounding = -1 # -1 default circle, -2 follow input-field rounding
          outer_color = rgb(150, 150, 150)
          inner_color = rgb(16, 16, 19)
          font_color = rgb(255, 255, 255)
          fade_on_empty = false
          fade_timeout = 1000 # Milliseconds before fade_on_empty is triggered.
          placeholder_text = <span foreground="##dddddd" style="italic">Password</span>
          hide_input = false
          rounding = -1 # -1 means complete rounding (circle/oval)
          check_color = rgb(15, 219, 255)
          fail_color = rgb(237, 37, 78) # if authentication failed, changes outer_color and fail message color
          fail_text = <i>$FAIL <b>($ATTEMPTS)</b></i>
          fail_transition = 300 # transition time in ms between normal outer_color and fail_color
          capslock_color = -1
          numlock_color = -1
          bothlock_color = -1 # when both locks are active. -1 means don't change outer color (same for above)
          invert_numlock = false # change color if numlock is off
          swap_font_color = false # see below

          position = 0, -80
          halign = center
          valign = center
      }

      label {
          monitor =
          text = $DESC
          color = rgba(255, 255, 255, 1.0)
          font_size = 25
          font_family = sans-serif
          rotate = 0 # degrees, counter-clockwise

          position = 0, 0
          halign = center
          valign = center

          shadow_passes = 1
          shadow_size = 5
          shadow_boost = 1.6
      }

      label {
          monitor =
          text = cmd[update:30000] echo "$(date +"%A, %B %-d | %I:%M %p") | $(${pkgs.nushell}/bin/nu ${inputs.self}/res/bat_display.nu)"
          color = rgba(255, 255, 255, 1.0)
          font_size = 20
          font_family = sans-serif
          rotate = 0 # degrees, counter-clockwise

          position = 0, -40
          halign = center
          valign = top

          shadow_passes = 1
          shadow_size = 5
          shadow_boost = 1.6
      }
    '';
  };
}
