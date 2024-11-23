{...}: {
  # When squint and don't think about it, audio is graphics
  hardware.pulseaudio.enable = false;

  security.rtkit.enable = true; # Allows pipewire and friends to run realtime

  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };
}
