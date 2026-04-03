{
  config,
  lib,
  ...
}: {
  options.cow.audio = {
    enable = lib.mkEnableOption "audio config with Pipewire";
  };

  config = let
    conf = config.cow.audio;
  in
    lib.mkIf conf.enable {
      services.pulseaudio.enable = false;
      services.pipewire = {
        enable = true;
        pulse.enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
      };

      users.users = lib.mkIf config.cow.bean.enable {
        bean.extraGroups = ["audio"];
      };
    };
}
