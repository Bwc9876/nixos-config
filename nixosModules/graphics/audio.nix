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
      ",XF86AudioRaiseVolume,exec,uwsm app -- swayosd-client --output-volume raise"
      ",XF86AudioLowerVolume,exec,uwsm app -- swayosd-client --output-volume lower"
      ",XF86AudioMute,exec,uwsm app -- swayosd-client --output-volume mute-toggle"
    ];
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
  };
}
