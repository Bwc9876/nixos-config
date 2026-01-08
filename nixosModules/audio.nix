{inputs, ...}: {
  config,
  lib,
  ...
}: {
  imports = [inputs.musnix.nixosModules.musnix];

  options.cow.audio = {
    enable = lib.mkEnableOption "audio config with Pipewire";
    tweaks = {
      enable = lib.mkEnableOption "audio performance tweaks with musnix";
      threadirqs = lib.mkEnableOption "threadirqs kernel param";
      soundCard = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = "PCI ID of the primary soundcard (lspci | grep -i audio)";
        default = null;
      };
    };
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

      musnix = lib.mkIf conf.tweaks.enable {
        enable = true;
        rtcqs.enable = true;
        soundcardPciId = lib.mkIf (conf.tweaks.soundCard != null) conf.tweaks.soundCard;
      };

      boot.kernelParams = lib.mkIf (conf.tweaks.threadirqs) ["threadirqs"];

      users.users = lib.mkIf config.cow.bean.enable {
        bean.extraGroups = ["audio"];
      };
    };
}
