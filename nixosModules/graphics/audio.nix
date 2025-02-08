{pkgs, ...}: {
  # When you squint and don't think about it, audio is graphics (I don't wanna make anoher role bc why would I do that)
  services.pulseaudio.enable = false;

  security.rtkit.enable = true; # Allows pipewire and friends to run realtime

  environment.systemPackages = with pkgs; [
    playerctl
  ];

  services.playerctld.enable = true;

  home-manager.users.bean.wayland.windowManager.hyprland.settings = {
    bindl = [
      ",XF86AudioPlay,exec,playerctl play-pause"
      ",XF86AudioPause,exec,playerctl pause"
      ",XF86AudioStop,exec,playerctl stop"
      ",XF86AudioNext,exec,playerctl next"
      ",XF86AudioPrev,exec,playerctl previous"
    ];
    bindel = [
      ",XF86AudioRaiseVolume,exec,swayosd-client --output-volume raise"
      ",XF86AudioLowerVolume,exec,swayosd-client --output-volume lower"
      ",XF86AudioMute,exec,swayosd-client --output-volume mute-toggle"
    ];
  };

  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    extraConfig.pipewire = {
      "92-low-latency" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 2048;
          "default.clock.min-quantum" = 2048;
          "default.clock.max-quantum" = 2048;
        };
      };
    };
    extraConfig.pipewire-pulse."92-low-latency" = {
      context.modules = [
        {
          name = "libpipewire-module-protocol-pulse";
          args = {
            pulse.min.req = "1024/48000";
            pulse.default.req = "1024/48000";
            pulse.max.req = "1024/48000";
            pulse.min.quantum = "1024/48000";
            pulse.max.quantum = "1024/48000";
          };
        }
      ];
      stream.properties = {
        node.latency = "1024/48000";
        resample.quality = 1;
      };
    };
  };
}
