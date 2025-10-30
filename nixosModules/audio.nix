{...}: {
  config,
  lib,
  ...
}: {
  options.cow.audio.enable = lib.mkEnableOption "audo config with Pipewire";

  config = lib.mkIf config.cow.audio.enable {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true; # Allows pipewire and friends to run realtime
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
    };
  };
}
