{
  config,
  lib,
  pkgs,
  ...
}: {
  options.cow.noctalia = {
    enable = (lib.mkEnableOption "noctalia + customizations") // {default = config.cow.gdi.enable;};
  };

  config = let
    conf = config.cow.noctalia;
  in
    lib.mkIf conf.enable {
      home.packages = with pkgs; [
        gpu-screen-recorder
        wl-mirror
        hyprpicker
      ];

      programs.noctalia = {
        enable = true;

        systemd.enable = true;

        settings = {
          storage = {
            key_source = "secret-service";
          };
          shell = {
            setup_wizard_enabled = false;
            niri_overview_type_to_launch_enabled = true;
            polkit_agent = true;
            avatar_path = lib.mkIf config.cow.pictures.enable config.cow.pictures.pfp;
            launch_apps_as_systemd_services = true;
            screenshot = {
              pipe_to_command = true;
              pipe_command = "${lib.getExe pkgs.swappy} -f -";
            };
          };
          lockscreen = {
            blurred_desktop = true;
          };
          bar.default = {
            start = ["media" "noctalia/bongocat:cat" "audio_visualizer"];
            center = ["clock"];
            end = ["tray" "notifications" "clipboard" "network" "bluetooth" "volume" "brightness" "battery" "dotnetrob/cat:cat" "control-center" "session"];
          };
          widget = {
            clock = {
              format = "{:%-H:%M} | {:%A, %B %-d}";
            };
            "noctalia/bongocat:cat" = {
              audio_spectrum = true;
              tappy_mode = true;
              use_mpris_filter = true;
            };
          };
          idle.behavior =
            if config.cow.gdi.doIdle
            then {
              lock = {
                timeout = 120 + 4;
                enabled = true;
              };
              screen-off = {
                timeout = 120;
                enabled = true;
              };
              suspend.timeout = 60 * 5;
            }
            else {
              suspend.enabled = false;
            };
          nightlight.enabled = true;
          location.auto_locate = true;
          audio.enable_overdrive = true;
          theme = {
            mode = "dark";
          };
          wallpaper = lib.mkIf config.cow.pictures.enable {
            enabled = true;
            default.path = config.cow.pictures.bg;
          };
          plugins = {
            source = [
              {
                name = "official";
                kind = "path";
                location = pkgs.fetchFromGitHub {
                  owner = "noctalia-dev";
                  repo = "official-plugins";
                  rev = "f5d7f8049da8b7e830b6d3d57761bb869e46cede";
                  hash = "sha256-mYUomM1N+7eD65g6Mdfntn5rMrUBcH6T1BZuDBj3OmI=";
                };
              }
              {
                name = "unofficial";
                kind = "path";
                location = pkgs.fetchFromGitHub {
                  owner = "noctalia-dev";
                  repo = "community-plugins";
                  rev = "ea86850b8c21f9f8f3663021163b8f071040986d";
                  hash = "sha256-7I7A4EuxiRTRZycDOErPP8oSdtAcv7zhJEpQU+S2mq0=";
                };
              }
            ];
            enabled = [
              "noctalia/screen_recorder"
              "noctalia/bongocat"
              "dotnetrob/cat"
              "elijaharch/wl-screen-mirror"
              "oldirtty/color_picker"
            ];
          };
          plugin_settings = {
            "noctalia/screen_recorder" = {
              directory = "~/Videos/Captures";
            };
          };
        };
      };
    };
}
